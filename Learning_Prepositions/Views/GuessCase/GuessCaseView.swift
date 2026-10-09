import SwiftUI

struct GuessCaseView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var nav: NavigationViewModel
    @StateObject private var viewModel = GuessCaseViewModel()
    @State private var showExitAlert = false
    @State private var flip = false
    @State private var prepositionSheetItem: PrepositionDetailSheetItem?
    @State private var didStartSession = false

    private var isCompactHeight: Bool {
        UIScreen.main.bounds.height <= 667
    }

    private var sectionSpacing: CGFloat {
        isCompactHeight ? 14 : 24
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView(
                    title: "\(L10n.Prepositions.GuessCase.title) \(viewModel.currentIndex + 1)/\(max(viewModel.totalQuestions, 1))",
                    showExitAlert: $showExitAlert
                )
                .padding(.top, isCompactHeight ? 8 : 16)
                .padding(.bottom, isCompactHeight ? 8 : 12)

                if let word = viewModel.currentWord {
                    questionSection(word: word)
                        .padding(.horizontal, 16)
                        .padding(.bottom, isCompactHeight ? 8 : 12)

                    if viewModel.isAnswered {
                        VStack(spacing: sectionSpacing) {
                            answeredHeaderSection(word: word)
                            translationSection(word: word)
                            PrepositionLearnMoreButton(
                                lemma: word.preposition,
                                isProminent: viewModel.selectedAnswer != word.quizCase?.rawValue,
                                articleSource: .quiz,
                                onOpenDetail: { prepositionSheetItem = $0 }
                            )
                        }
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .id(viewModel.currentIndex)
                        .transition(.opacity)
                    } else {
                        Spacer(minLength: 0)
                    }

                    actionButtonSection
                } else if !viewModel.isLoading {
                    Spacer()
                    Text(L10n.AppErrors.contentNotAvailable)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(24)
                    Spacer()
                } else {
                    Spacer()
                }
            }

            if viewModel.isLoading && viewModel.wordItems.isEmpty {
                Color.black.opacity(0.4).ignoresSafeArea()
                CardLoaderView()
            }
        }
        .background(AppTheme.mainGradient.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isAnswered)
        .showAlert(
            title: L10n.Alert.FinishTest.title,
            description: L10n.Alert.FinishTest.description,
            isPresented: $showExitAlert,
            onExit: {
                viewModel.logAbandonedIfNeeded()
                dismiss()
            }
        )
        .errorAlert(isPresented: $viewModel.showError, error: viewModel.appError) {
            Task { await viewModel.startOrRestart() }
        }
        .onAppear {
            if viewModel.isSessionCompleted || !didStartSession {
                didStartSession = true
                Task { await viewModel.startOrRestart() }
            }
        }
        .prepositionDetailSheet(item: $prepositionSheetItem)
    }

    private func questionSection(word: WordItem) -> some View {
        VStack(spacing: isCompactHeight ? 14 : 24) {
            Text(L10n.Prepositions.GuessCase.prompt)
                .font(.system(isCompactHeight ? .subheadline : .headline, design: .rounded))
                .foregroundStyle(.secondary)

            ZStack {
                QuestionCard(
                    item: word,
                    isAnswered: viewModel.isAnswered,
                    isCompactHeight: isCompactHeight,
                    alwaysHighlightPreposition: true
                )
                .id("q_\(word.id)")

                if viewModel.isAnswered {
                    AnswerCelebrationOverlay(
                        isCorrect: viewModel.selectedAnswer == word.quizCase?.rawValue
                    )
                }
            }
            .padding(.horizontal, 8)

            VStack(spacing: isCompactHeight ? 10 : 14) {
                ForEach(viewModel.caseOptions, id: \.self) { option in
                    Button {
                        viewModel.selectAnswer(option.rawValue)
                    } label: {
                        Text(option.rawValue)
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundStyle(isColored(option.rawValue) ? .white : .primary)
                            .frame(maxWidth: .infinity, minHeight: isCompactHeight ? 52 : 60)
                            .background(backgroundColor(for: option.rawValue))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(viewModel.isAnswered)
                }
            }
            .padding(.horizontal, 4)
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
        .animation(.easeInOut(duration: 0.35), value: viewModel.currentIndex)
    }

    private func answeredHeaderSection(word: WordItem) -> some View {
        VStack(spacing: isCompactHeight ? 8 : 12) {
            HStack(alignment: .center, spacing: 10) {
                Text(word.formattedTranslation(for: viewModel.currentLanguage))
                    .font(.system(isCompactHeight ? .subheadline : .title3, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(1)

                Button {
                    Speaker.shared.speak(word.basePreposition)
                } label: {
                    Image(systemName: "speaker.wave.2.circle.fill")
                        .font(isCompactHeight ? .title3 : .title2)
                        .foregroundStyle(.blue)
                }
            }
            .padding(.horizontal, isCompactHeight ? 16 : 20)
            .padding(.vertical, isCompactHeight ? 8 : 12)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )

            Text(word.quizCase?.rawValue ?? word.caseType)
                .font(isCompactHeight ? .subheadline : .headline)
                .fontWeight(.bold)
                .foregroundStyle(word.caseColor)
                .frame(width: isCompactHeight ? 120 : 140, height: isCompactHeight ? 36 : 44)
                .background(
                    Capsule()
                        .fill(word.caseColor.opacity(0.15))
                )
                .overlay(
                    Capsule().strokeBorder(word.caseColor.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: word.caseColor.opacity(0.2), radius: 8, y: 4)
                .rotation3DEffect(
                    .degrees(flip ? 0 : 180),
                    axis: (x: 0, y: 1, z: 0)
                )
                .onAppear {
                    flip = false
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        flip = true
                    }
                }
        }
        .padding(.horizontal, 4)
    }

    private func translationSection(word: WordItem) -> some View {
        Text(word.translation(for: viewModel.currentLanguage))
            .font(isCompactHeight ? .callout : .body)
            .multilineTextAlignment(.center)
            .foregroundStyle(.primary)
            .lineLimit(isCompactHeight ? 3 : 4)
            .padding(.horizontal, 8)
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var actionButtonSection: some View {
        if viewModel.isAnswered {
            Group {
                if viewModel.currentIndex + 1 == viewModel.totalQuestions {
                    AppButton(
                        title: L10n.Quiz.Button.finish, minHeight: 56, background: .blue
                    ) {
                        viewModel.saveResult()
                        let context = QuizResultContext(
                            correctAnswers: viewModel.correctAnswers,
                            resultsHistory: viewModel.resultsHistory,
                            gameType: .guessCase,
                            numberOfQuestions: viewModel.totalQuestions
                        )
                        nav.goTo(.result(context))
                    }
                } else {
                    AppButton(title: L10n.Quiz.Button.next, minHeight: 56, background: .yellow) {
                        withAnimation {
                            viewModel.nextQuestion()
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, isCompactHeight ? 12 : 20)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    private func isColored(_ text: String) -> Bool {
        let color = viewModel.buttonColor(for: text)
        return color != .white && color != .clear
    }

    private func backgroundColor(for text: String) -> Color {
        let vmColor = viewModel.buttonColor(for: text)
        if vmColor == .white {
            return Color(UIColor.secondarySystemGroupedBackground)
        }
        return vmColor
    }
}
