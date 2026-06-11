import SwiftUI

struct TrainingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: TrainingViewModel
    @EnvironmentObject private var nav: NavigationViewModel
    @State private var showExitAlert = false
    
    // ОПТИМИЗАЦИЯ: Показываем максимум 3 карты одновременно
    private let maxVisibleCards = 3
    
    init(items: [WordItem], category: Category) {
        _viewModel = StateObject(wrappedValue: TrainingViewModel(words: items, category: category))
    }
    
    var body: some View {
        VStack(spacing: 0) {
        HeaderView(
                title: L10n.Training.Screen.title,
                showExitAlert: $showExitAlert
            )
            .zIndex(100)            
            ZStack {
                if viewModel.words.isEmpty {
                    TrainingCompletionView(
                        onFinish: {
                            nav.backToRoot()
                        }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity.animation(.easeInOut))
                    
                } else {
                    ZStack {
                        ForEach(visibleWords(), id: \.id) { word in
                            FlashcardView(
                                word: word,
                                onRemove: { viewModel.removeTopCard() },
                                onReturn: { viewModel.returnCardToDeck() }
                            )
                            .scaleEffect(getScale(for: word))
                            .offset(y: getOffset(for: word))
                            .opacity(getOpacity(for: word))
                            .allowsHitTesting(word.id == viewModel.words.last?.id)
                            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                            .transition(.asymmetric(insertion: .identity, removal: .identity))
                        }
                    }
                    .padding(.horizontal, 16)
                    }
            }
            .frame(maxHeight: .infinity)
            
            if !viewModel.words.isEmpty {
                controlsHintView
                    .padding(.bottom, 20)
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
    
    private func visibleWords() -> [WordItem] {
        return Array(viewModel.words.suffix(maxVisibleCards))
    }
    
    private func getScale(for word: WordItem) -> CGFloat {
        guard let index = visibleWords().firstIndex(where: { $0.id == word.id }) else { return 1.0 }
        let reverseIndex = CGFloat(visibleWords().count - 1 - index)
        return 1.0 - (reverseIndex * 0.05)
    }
    
    private func getOffset(for word: WordItem) -> CGFloat {
        guard let index = visibleWords().firstIndex(where: { $0.id == word.id }) else { return 0 }
        let reverseIndex = CGFloat(visibleWords().count - 1 - index)
        return reverseIndex * 15
    }
    
    // Прозрачность (самая нижняя карта чуть прозрачнее, чтобы красиво появлялась)
    private func getOpacity(for word: WordItem) -> Double {
        guard let index = visibleWords().firstIndex(where: { $0.id == word.id }) else { return 1.0 }
        if visibleWords().count < maxVisibleCards { return 1.0 }
        return index == 0 ? 0.5 : 1.0
    }
    
    // MARK: - Components
    
    private var controlsHintView: some View {
        HStack {
            HintCapsule(
                text: L10n.Training.Action.repeat,
                icon: "arrow.counterclockwise",
                color: .red
            )
            .opacity(0.9)            
            Spacer()
            
            HintCapsule(
                text: L10n.Training.Action.know,
                icon: "checkmark",
                color: .green
            )
            .opacity(0.9)
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 10)
    }
}

#Preview {
    TrainingView(items: [], category: .verben)
}
