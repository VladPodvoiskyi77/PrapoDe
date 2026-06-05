import SwiftUI

struct TrainingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: TrainingViewModel
    @EnvironmentObject private var nav: NavigationViewModel
    @State private var showExitAlert = false
    
    // ОПТИМИЗАЦИЯ: Показываем максимум 3 карты одновременно
    // Это спасает память и делает анимацию плавной
    private let maxVisibleCards = 3
    
    init(items: [WordItem], category: Category) {
        _viewModel = StateObject(wrappedValue: TrainingViewModel(words: items, category: category))
    }
    
    var body: some View {
        VStack(spacing: 0) { // spacing: 0 важно для контроля отступов
            HeaderView(
                title: L10n.Training.Screen.title,
                showExitAlert: $showExitAlert
            )
            .zIndex(100) // Хедер всегда поверх карт
            
            // --- ОСНОВНАЯ ЗОНА ---
            ZStack {
                if viewModel.words.isEmpty {
                    // Экран завершения
                    TrainingCompletionView(
                        onFinish: {
                            nav.backToRoot()
                        }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity.animation(.easeInOut))
                    
                } else {
                    // --- КОЛОДА КАРТ ---
                    ZStack {
                        // Рендерим только последние 3 элемента (верх колоды)
                        ForEach(visibleWords(), id: \.id) { word in
                            FlashcardView(
                                word: word,
                                onRemove: { viewModel.removeTopCard() },
                                onReturn: { viewModel.returnCardToDeck() }
                            )
                            // ВИЗУАЛ: Эффект глубины
                            .scaleEffect(getScale(for: word))
                            .offset(y: getOffset(for: word))
                            .opacity(getOpacity(for: word))
                            // Блокируем нижние карты
                            .allowsHitTesting(word.id == viewModel.words.last?.id)
                            // Тень для объема
                            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                            // Анимация при удалении
                            .transition(.asymmetric(insertion: .identity, removal: .identity))
                        }
                    }
                    .padding(.horizontal, 16) // Отступы по бокам, чтобы карты не липли
                }
            }
            .frame(maxHeight: .infinity)
            
            // Подсказки
            if !viewModel.words.isEmpty {
                controlsHintView
                    .padding(.bottom, 20) // Безопасный отступ снизу
            }
        }
        .background(
            AppTheme.mainGradient.ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)
        .showAlert(
            title: L10n.Alert.FinishTraining.title,
            isPresented: $showExitAlert,
            onExit: { dismiss() }
        )
        .onAppear {
            viewModel.logSessionStarted()
        }
        .onChange(of: viewModel.words.count) { oldCount, newCount in
            if oldCount > 0 && newCount == 0 {
                viewModel.logSessionFinished()
            }
        }
    }
    
    // MARK: - Optimization & Visuals
    
    // Берем только "хвост" массива (верх колоды)
    private func visibleWords() -> [WordItem] {
        // suffix возвращает последние N элементов.
        // Array(...) превращает Slice обратно в Array для ForEach
        return Array(viewModel.words.suffix(maxVisibleCards))
    }
    
    // Расчет масштаба (Верхняя карта = 1.0, Нижняя = 0.95)
    private func getScale(for word: WordItem) -> CGFloat {
        guard let index = visibleWords().firstIndex(where: { $0.id == word.id }) else { return 1.0 }
        let reverseIndex = CGFloat(visibleWords().count - 1 - index)
        // Чем глубже карта, тем она меньше (шаг 0.05)
        return 1.0 - (reverseIndex * 0.05)
    }
    
    // Расчет смещения (Верхняя = 0, Нижняя = чуть ниже)
    private func getOffset(for word: WordItem) -> CGFloat {
        guard let index = visibleWords().firstIndex(where: { $0.id == word.id }) else { return 0 }
        let reverseIndex = CGFloat(visibleWords().count - 1 - index)
        // Чем глубже карта, тем она ниже (шаг 15pt)
        return reverseIndex * 15
    }
    
    // Прозрачность (самая нижняя карта чуть прозрачнее, чтобы красиво появлялась)
    private func getOpacity(for word: WordItem) -> Double {
        guard let index = visibleWords().firstIndex(where: { $0.id == word.id }) else { return 1.0 }
        // Если это 3-я карта (самая нижняя), делаем её чуть прозрачной при появлении
        // Но если карт всего 2 или 1, они всегда 1.0
        if visibleWords().count < maxVisibleCards { return 1.0 }
        return index == 0 ? 0.5 : 1.0
    }
    
    // MARK: - Components
    
    private var controlsHintView: some View {
        HStack {
            // "Повторить" (Красный)
            HintCapsule(
                text: L10n.Training.Action.repeat,
                icon: "arrow.counterclockwise",
                color: .red
            )
            .opacity(0.9) // Чуть приглушаем, чтобы не отвлекало от карт
            
            Spacer()
            
            // "Знаю" (Зеленый)
            HintCapsule(
                text: L10n.Training.Action.know,
                icon: "checkmark",
                color: .green
            )
            .opacity(0.9)
        }
        .padding(.horizontal, 30)
        // Для iPhone с кнопкой "Домой" нужен отступ снизу
        // Для iPhone X+ Safe Area справится сама, но padding(.bottom) добавляет воздух
        .padding(.bottom, 10)
    }
}

#Preview {
    TrainingView(items: [], category: .verben)
}
