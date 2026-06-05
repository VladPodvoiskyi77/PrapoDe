import SwiftUI
import WidgetKit

struct MyProgressView: View {
    @StateObject private var viewModel: MyProgressViewModel
    @State private var showInfoSheet = false
    @State private var showConfirmUpdate = false
    @State private var showUpdateStatus = false
    @State private var updateResult: UpdateResult = .noChanges // Твой Enum
    
    let category: Category
    
    init(category: Category) {
        self.category = category
        _viewModel = StateObject(wrappedValue: MyProgressViewModel(category: category))
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            
            // --- СЛОЙ 1: СПИСОК СЛОВ ---
            VStack(spacing: 0) {
                MyProgressHeaderView(
                    learnedCount: viewModel.learnedWords,
                    totalCount: viewModel.totalWords,
                    progress: viewModel.progressValue,
                    level: viewModel.currentLevelRaw,
                    category: category.rawValue
                )
                .padding()
                
                List(viewModel.filteredWords) { word in
                    WordRowView(
                        base: word.base,
                        preposition: word.preposition,
                        translation: word.translationWordWithPrep(for: viewModel.currentLanguage),
                        caseType: word.caseType,
                        mode: .learning(score: word.learningScore, isLearned: word.isLearned)
                    )
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .background(AppTheme.mainGradient.ignoresSafeArea())
            .animation(.default, value: viewModel.showFilterCarousel)
            
            // --- СЛОЙ 2: ФИЛЬТР (КАРУСЕЛЬ) ---
            if viewModel.showFilterCarousel {
                // 1. Прозрачный фон для отмены
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // ТАП МИМО -> СБРОС И ЗАКРЫТИЕ
                        viewModel.closeAndResetFilter()
                    }
                    .zIndex(1)
                
                if !viewModel.availablePrepositions.isEmpty  {
                    // 2. Сама карусель
                    FloatingCarousel(
                        items: viewModel.availablePrepositions,
                        selectedItem: $viewModel.selectedPreposition,
                        onSelect: { prep in
                            viewModel.activePreposition = prep
                            withAnimation {
                                viewModel.showFilterCarousel = false
                            }
                        },
                        isOpen: viewModel.showFilterCarousel
                    )
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                    .zIndex(2)
                    .padding(.bottom, 20) // Положение по вертикали
                }
                
                
            }
            
            // СЛОЙ 3: Лоадер (Поверх всего, по центру)
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea() // Затемнение фона
                    CardLoaderView()
                        .transition(.scale.combined(with: .opacity)) // Плавное появление
                }
                .zIndex(100)
            }
        }
        .opacity(viewModel.isLoading ? 0.5 : 1)
        .disabled(viewModel.isLoading)
        
        // --- НАВИГАЦИЯ ---
        .navigationTitle(L10n.MyProgress.Screen.title)
        .navigationBarTitleDisplayMode(.inline)
        
        .searchable(
            text: $viewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .automatic),
            prompt: Text(L10n.MyProgress.Search.title)
        )
        
        .toolbar {
            // info button
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showInfoSheet = true
                } label: {
                    Image(systemName: "questionmark.circle")
                        .fontWeight(.medium)
                }
            }
            // update data
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showConfirmUpdate = true
                    // показать алерт с вопросом - обновить данные или нет? если да, сделать уже запрос
                } label: {
                    Image(systemName: "arrow.clockwise.icloud")
                        .fontWeight(.medium)
                }
            }
            // filter button
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    
                    // Кнопка Фильтра
                    Button {
                        if viewModel.showFilterCarousel {
                            
                            viewModel.closeAndResetFilter()
                        } else {
                            withAnimation(.spring()) {
                                viewModel.showFilterCarousel = true
                            }
                        }
                    } label: {
                        // Логика цвета иконки
                        let isOpen = viewModel.showFilterCarousel
                        
                        Image(systemName:
                                isOpen
                              ? "line.3.horizontal.decrease.circle.fill"
                              : "line.3.horizontal.decrease.circle"
                        )
                    }
                    
                }
            }
        }
        .sheet(isPresented: $showInfoSheet) {
            LearningRulesView(context: .general)
                .presentationDetents([ .large]) // Шторка открывается наполовину
                .presentationDragIndicator(.visible)
        }
        .errorAlert(isPresented: $viewModel.showError, error: viewModel.appError) {
            Task {
                await viewModel.loadData()
            }
        }
        .showAlert(title: L10n.MyProgress.Update.Alert.Confirm.title,
                   description: L10n.MyProgress.Update.Alert.Confirm.description,
                   isPresented: $showConfirmUpdate,
                   onExit: {
            viewModel.refreshData()
        })
        .statusAlert(title: viewModel.statusAlertTitle,
                     description: viewModel.statusAlertDescription,
                     isPresented: $viewModel.showStatusAlert)
        .onAppear {
            AnalyticsManager.shared.logMyProgressViewed(
                category: category.rawValue,
                level: viewModel.currentLevelRaw
            )
        }
    }
}

//#Preview {
//    MyProgressView(category: .verben)
//}
