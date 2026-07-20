import SwiftUI

struct UniversalMenuView: View {
    // MARK: - Properties
    let type: MenuScreenType
    let category: Category
    
    @EnvironmentObject private var nav: NavigationViewModel
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var viewModel: UniversalMenuViewModel
    
    @State private var showSettings = false
    @State private var isRotating = false
    @State private var isMenuVisible = false
    
    init(type: MenuScreenType, category: Category) {
        self.type = type
        self.category = category
        _viewModel = StateObject(wrappedValue: UniversalMenuViewModel(type: type, category: category))
    }
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            VStack(spacing: 24) {
                
                Text(viewModel.screenTitle)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 60)
                    .padding(.horizontal, 24)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(Array(viewModel.menuItems.enumerated()), id: \.element.id) { index, item in
                            MenuCard(
                                title: item.title,
                                iconName: item.iconName,
                                iconColor: item.iconColor,
                                staggerIndex: index,
                                isMenuVisible: isMenuVisible,
                                action: { handleSelection(item) }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
                
                Spacer()
            }
            .background(
                AppTheme.mainGradient.ignoresSafeArea()
            )
            
            if viewModel.showLevelHint {
                LevelHintView {
                    viewModel.markHintAsSeen()
                }
                .padding(.top, 5)
                .padding(.trailing, 16)
                .transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .topTrailing)))
                .zIndex(100)
            }
            
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    CardLoaderView()
                        .transition(.scale.combined(with: .opacity))
                }
                .zIndex(100)
            }
            
        }
        
        .toolbar {
            if type == .main {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        nav.goTo(.prepositionsList)
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .fontWeight(.medium)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    settingsButton
                        .simultaneousGesture(TapGesture().onEnded {
                            viewModel.markHintAsSeen()
                        })
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        
        .onAppear {
            if type == .main {
                let currentNickname = UserProfileManager.shared.userNickname
                AnalyticsManager.shared.logAppLaunch(
                    userId: UserProfileManager.shared.currentUid,
                    nickname: currentNickname
                )
                WidgetAnalyticsService.sync()
                Task {
                    await viewModel.performStartupCheck(context: modelContext)
                }
            }
            withAnimation(.easeOut(duration: 0.4)) {
                showSettings = type == .main
            }
            isMenuVisible = false
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isMenuVisible = true
            }
        }
        .onDisappear {
            isMenuVisible = false
        }
        .errorAlert(isPresented: $viewModel.showError, error: viewModel.appError) {
            fetchDataAndShowView(selectedMode: nav.selectedMode)
        }
    }
    
    // MARK: - Components
    
    private var settingsButton: some View {
        Button(action: openSettings) {
            Image(systemName: "gearshape.fill")
                .font(.title2)
                .foregroundStyle(.primary)
                .rotationEffect(.degrees(isRotating ? 180 : 0))
                .padding(10)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                .opacity(showSettings ? 1 : 0)
                .offset(x: showSettings ? 0 : 30)
        }
    }
    
    // MARK: - Logic & Actions
    
    private func openSettings() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            isRotating.toggle()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            nav.goTo(.settings)
        }
    }
    
    private func handleSelection(_ item: MenuUIItem) {
        viewModel.markHintAsSeen()
        switch item.payload {
        case .category(let selectedCategory):
            nav.goTo(.activity(selectedCategory))
            
        case .mode(let selectedMode):
            nav.selectedMode = selectedMode
            
            switch selectedMode {
                
            case .sprint, .writing:
                fetchDataAndShowView(selectedMode: selectedMode)
            case .myProgress:
                nav.goTo(.myProgress(category))
            default:
                nav.goTo(.mode(category, selectedMode))
            }
        }
    }
    
    private func fetchDataAndShowView(selectedMode: Activity) {
        Task {
            let words = await viewModel.loadWords()
            
            await MainActor.run {
                if !words.isEmpty {
                    
                    switch selectedMode {
                    case .sprint:
                        nav.goTo(.chooseQuizLevel(words, category.rawValue))
                    default:
                        nav.goTo(.writing(words, category))
                    }
                }
            }
        }
    }
}
