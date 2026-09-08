import SwiftUI

struct QuizView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var nav: NavigationViewModel
    @StateObject private var viewModel: QuizViewModel
    @State private var showExitAlert = false
    @State private var flip = false
    @State private var prepositionSheetItem: PrepositionDetailSheetItem?
    @State private var didStartSession = false

    init(items: [WordItem], filteredItem: [WordItem], categoryName: String) {
        _viewModel = StateObject(wrappedValue: QuizViewModel(fullWordItems: items, filteredItem: filteredItem, categoryName: categoryName))
    }

    private var isCompactHeight: Bool {
        UIScreen.main.bounds.height <= 667
    }

    private var sectionSpacing: CGFloat {
        isCompactHeight ? 14 : 24
    }

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                title: L10n.Quiz.title + " \(viewModel.currentIndex + 1)/\(viewModel.totalQuestions)",
                showExitAlert: $showExitAlert
            )
            .padding(.top, isCompactHeight ? 8 : 16)
            .padding(.bottom, isCompactHeight ? 8 : 12)

            questionSection
                .padding(.horizontal, 16)
                .padding(.bottom, isCompactHeight ? 8 : 12)

            if viewModel.isAnswered {
                VStack(spacing: sectionSpacing) {
                    answeredHeaderSection
                    translationSection
                    PrepositionLearnMoreButton(
                        lemma: viewModel.currentWord.preposition,
                        isProminent: viewModel.selectedAnswer != viewModel.currentWord.preposition,
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
        }
        .background(AppTheme.mainGradient.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isAnswered)
        .showAlert(title: L10n.Alert.FinishTest.title,
                   description: L10n.Alert.FinishTest.description,
                   isPresented: $showExitAlert,
                   onExit: {
            viewModel.logAbandonedIfNeeded()
            dismiss()
        })
        .onAppear {
            if viewModel.isSessionCompleted {
                viewModel.refreshData()
            } else if !didStartSession {
                didStartSession = true
                viewModel.refreshData()
            }
        }
        .prepositionDetailSheet(item: $prepositionSheetItem)
    }

    @ViewBuilder
    private var answeredHeaderSection: some View {
        VStack(spacing: isCompactHeight ? 8 : 12) {
            HStack(alignment: .center, spacing: 10) {
                Text(viewModel.currentWord.formattedTranslation(for: viewModel.currentLanguage))
                    .font(.system(isCompactHeight ? .subheadline : .title3, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(1)

                Button {
                    Speaker.shared.speak(viewModel.currentWord.basePreposition)
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
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )

            Text(viewModel.currentWord.caseType)
                .font(isCompactHeight ? .subheadline : .headline)
                .fontWeight(.bold)
                .foregroundStyle(caseColor)
                .frame(width: isCompactHeight ? 120 : 140, height: isCompactHeight ? 36 : 44)
                .background(
                    Capsule()
                        .fill(caseColor.opacity(0.15))
                )
                .overlay(
                    Capsule().strokeBorder(caseColor.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: caseColor.opacity(0.2), radius: 8, y: 4)
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

    private var questionSection: some View {
        ZStack {
            ForEach(Array(viewModel.wordItems.enumerated()), id: \.element.id) { index, item in
                if index == viewModel.currentIndex {
                    QuestionBlock(viewModel: viewModel, item: item, isCompactHeight: isCompactHeight)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
        }
        .animation(.easeInOut(duration: 0.35), value: viewModel.currentIndex)
    }

    private var translationSection: some View {
        Text(viewModel.wordItems[viewModel.currentIndex].translation(for: viewModel.currentLanguage))
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
                            gameType: .quiz,
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

    private var caseColor: Color {
        viewModel.currentWord.caseColor
    }
}
