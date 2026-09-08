import SwiftUI

struct ModeView: View {
    let category: Category
    @EnvironmentObject private var nav: NavigationViewModel
    @StateObject private var viewModel: ModeViewModel
    @State private var lastSelectedMode: ModeType?
    
    init(category: Category, appMode: Activity) {
        self.category = category
        _viewModel = StateObject(wrappedValue: ModeViewModel(category: category, appMode: appMode))
    }
    
    var body: some View {
        ZStack {
            
            AppTheme.mainGradient
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text(L10n.Mode.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 60)
                    .padding(.horizontal, 24)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(viewModel.availableModes, id: \.self) { mode in
                            MenuCard(
                                title: mode.title,
                                iconName: mode.iconName,
                                iconColor: mode.iconColor,
                                action: {
                                    handleModeSelection(mode)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
            .opacity(viewModel.isLoading ? 0.5 : 1)
            .disabled(viewModel.isLoading)
            
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    CardLoaderView()
                        .transition(.scale.combined(with: .opacity))
                        }
                    .zIndex(100)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .errorAlert(isPresented: $viewModel.showError, error: viewModel.appError) {
            if let last = lastSelectedMode {
                handleModeSelection(last)
            }
        }
    }
    // MARK: - Navigation Logic
    
    private func handleModeSelection(_ mode: ModeType) {
        lastSelectedMode = mode
        Task {
            if let filteredWords = await viewModel.prepareWords(for: mode) {
                switch nav.selectedMode {
                case .training:
                    nav.goTo(.training(viewModel.allWords, filteredWords, category))
                case .quiz:
                    nav.goTo(.quiz(viewModel.allWords, filteredWords, category.rawValue))
                default:
                    nav.goTo(.training(viewModel.allWords, filteredWords, category))
                }
            }
        }
    }
}

#Preview {
    ModeView(category: .adjektive, appMode: .quiz)
}
