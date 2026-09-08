import SwiftUI

struct TrainingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: TrainingViewModel
    @EnvironmentObject private var nav: NavigationViewModel
    @State private var showExitAlert = false
    @State private var plusOnePulse = 0
    @State private var prepositionSheetItem: PrepositionDetailSheetItem?

    private let maxVisibleCards = 3

    init(allWords: [WordItem], deckWords: [WordItem], category: Category) {
        _viewModel = StateObject(
            wrappedValue: TrainingViewModel(
                allWords: allWords,
                deckWords: deckWords,
                category: category
            )
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                title: L10n.Training.Screen.title,
                showExitAlert: $showExitAlert
            )
            .zIndex(100)
            if !viewModel.isComplete && !viewModel.showBatchCheckpoint && viewModel.currentBatchSize > 0 {
                Text(batchProgressText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 8)
            }

            ZStack {
                if viewModel.isComplete {
                    TrainingCompletionView(
                        stats: viewModel.sessionStats,
                        reviewedCount: viewModel.sessionStats.markedKnown,
                        onFinish: {
                            nav.backToRoot()
                        }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity.animation(.easeInOut))

                } else if viewModel.showBatchCheckpoint {
                    TrainingBatchCheckpointView(
                        reviewedInBatch: viewModel.currentBatchSize,
                        remainingCount: viewModel.remainingCount,
                        onContinue: { viewModel.continueLearning() },
                        onFinish: { viewModel.finishFromCheckpoint() }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity.animation(.easeInOut))

                } else {
                    ZStack {
                        ForEach(visibleWords(), id: \.id) { word in
                            FlashcardView(
                                word: word,
                                onRemove: { viewModel.markKnown() },
                                onReturn: { viewModel.markRepeat() },
                                onKnowSwipe: { plusOnePulse += 1 },
                                onOpenPrepositionDetail: { prepositionSheetItem = $0 }
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
            .overlay(alignment: .bottomTrailing) {
                if !viewModel.words.isEmpty, plusOnePulse > 0 {
                    FloatingPlusOneLabel(color: .green)
                        .id(plusOnePulse)
                        .padding(.trailing, 40)
                        .padding(.bottom, 72)
                }
            }

            if !viewModel.words.isEmpty && !viewModel.showBatchCheckpoint && !viewModel.isComplete {
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
            onExit: {
                viewModel.logAbandonedIfNeeded()
                dismiss()
            }
        )
        .onAppear {
            viewModel.logSessionStarted()
        }
        .prepositionDetailSheet(item: $prepositionSheetItem)
        .onDisappear {
            viewModel.flushSave()
        }
        .onChange(of: viewModel.isComplete) { _, complete in
            if complete {
                viewModel.logSessionFinished()
            }
        }
    }

    private var batchProgressText: String {
        var text = L10n.Training.Batch.progress(viewModel.knownInBatch, viewModel.currentBatchSize)
        if viewModel.remainingCount > 0 {
            text += "  ·  " + L10n.Training.Batch.remaining(viewModel.remainingCount)
        }
        return text
    }

    // MARK: - Optimization & Visuals

    private func visibleWords() -> [WordItem] {
        Array(viewModel.words.suffix(maxVisibleCards))
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
    TrainingView(allWords: [], deckWords: [], category: .verben)
}
