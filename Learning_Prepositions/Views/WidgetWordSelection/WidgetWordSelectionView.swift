import SwiftUI
import SwiftData

struct WidgetWordSelectionView: View {
    @StateObject private var viewModel: WidgetWordSelectionViewModel
    @State private var showConfirmUpdate = false
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: WidgetWordSelectionViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            
            VStack(spacing: 0) {
                WidgetSelectionHeaderView(
                    selectedCount: viewModel.selectedCount,
                    totalCount: viewModel.totalCount,
                    level: viewModel.currentLevelRaw
                )
                .padding()
                
                List(viewModel.filteredWords) { word in
                    WordRowView(
                        base: word.base,
                        preposition: word.preposition,
                        translation: word.getTranslation(for: viewModel.currentLanguage),
                        caseType: word.caseTypeRaw,
                        mode: .selection(isOn: Binding(
                            get: { word.isShow },
                            set: { _ in viewModel.toggleWord(word) }
                        ))
                    )
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .background(AppTheme.mainGradient.ignoresSafeArea())
            
            if viewModel.showFilterCarousel {
                Color.black.opacity(0.001)
                    .onTapGesture { viewModel.closeAndResetFilter() }
                    .zIndex(1)
                
                if !viewModel.availablePrepositions.isEmpty {
                    FloatingCarousel(
                        items: viewModel.availablePrepositions,
                        selectedItem: $viewModel.selectedPreposition,
                        onSelect: { prep in
                            viewModel.selectedPreposition = prep
                            withAnimation { viewModel.showFilterCarousel = false }
                        },
                        isOpen: viewModel.showFilterCarousel
                    )
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                    .zIndex(2)
                    .padding(.bottom, 20)
                }
            }
            
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    CardLoaderView()
                }
                .zIndex(100)
            }
        }
        .opacity(viewModel.isLoading ? 0.5 : 1)
        .disabled(viewModel.isLoading)
        .onAppear {
            AnalyticsManager.shared.logScreenView("Widget_Word_Selection")
            AnalyticsManager.shared.logWidgetWordsConfigured(
                enabledCount: viewModel.selectedCount,
                totalCount: viewModel.totalCount
            )
        }
        .navigationTitle(L10n.WidgetWord.title)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.searchText, prompt: Text(L10n.WidgetWord.searchText))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showConfirmUpdate = true
                } label: {
                    Image(systemName: "arrow.clockwise.icloud")
                        .fontWeight(.medium)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.spring()) {
                        viewModel.showFilterCarousel.toggle()
                    }
                } label: {
                    Image(systemName: viewModel.showFilterCarousel
                          ? "line.3.horizontal.decrease.circle.fill"
                          : "line.3.horizontal.decrease.circle")
                }
            }
        }
        .errorAlert(isPresented: $viewModel.showError, error: viewModel.appError) {
            viewModel.retryAfterError()
        }
        .showAlert(
            title: L10n.MyProgress.Update.Alert.Confirm.title,
            description: L10n.MyProgress.Update.Alert.Confirm.description,
            isPresented: $showConfirmUpdate,
            onExit: {
                viewModel.refreshData()
            }
        )
        .statusAlert(
            title: viewModel.statusAlertTitle,
            description: viewModel.statusAlertDescription,
            isPresented: $viewModel.showStatusAlert
        )
    }
}
