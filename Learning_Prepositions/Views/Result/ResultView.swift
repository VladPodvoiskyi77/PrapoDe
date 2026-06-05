import SwiftUI

struct ResultView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var nav: NavigationViewModel
    @StateObject private var viewModel: ResultViewModel

    init(quizResultContext: QuizResultContext) {
        _viewModel = StateObject(
            wrappedValue: ResultViewModel(quizResultContext: quizResultContext)
        )
    }

    var body: some View {
        ZStack {
            AppTheme.mainGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                
                ResultScoreView(
                    correctAnswers: viewModel.quizResultContext.correctAnswers,
                    totalQuestions: viewModel.quizResultContext.numberOfQuestions
                )

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        menuButton(for: .review)
                        menuButton(for: .repeatTest)
                        menuButton(for: .leaderboard)
                        
                        if viewModel.quizResultContext.gameType == .sprint {
                            menuButton(for: .globalRanking)
                        }
                        
                        menuButton(for: .home)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
        .blockInteraction(for: 0.5)
        .onAppear {
            StoreReviewManager.requestReviewIfEligible(
                score: viewModel.quizResultContext.correctAnswers,
                total: viewModel.quizResultContext.numberOfQuestions,
                gameType: viewModel.quizResultContext.gameType
            )
        }
    }
    
    // MARK: - Subviews

    private var scoreSection: some View {
        VStack(spacing: 12) {
            Text(L10n.Result.result)
                .font(.title2)
                .bold()
                .foregroundStyle(.black.opacity(0.9))

            Text("\(viewModel.quizResultContext.correctAnswers)")
                .font(.system(size: 80, weight: .heavy, design: .rounded))
                .foregroundStyle(.black)
                .shadow(color: .white.opacity(0.2), radius: 10, x: 0, y: 5)

            Text(
                L10n.Result.correctAnswers(
                    viewModel.quizResultContext.correctAnswers
                )
            )
            .font(.headline)
            .foregroundStyle(.black.opacity(0.8))
        }
    }

    // MARK: - Menu Button

    private func menuButton(for type: ResultButtonType) -> some View {
        MenuCard(
            title: type.title,
            iconName: type.iconName,
            iconColor: type.color,
            action: {
                handleAction(for: type)
            }
        )
    }

    // MARK: - Actions

    private func handleAction(for type: ResultButtonType) {
        switch type {
        case .review:
            nav.goTo(.analysis(viewModel.quizResultContext.resultsHistory))

        case .repeatTest:
            dismiss()

        case .leaderboard:
            let resultContext = ResultContext(
                gameType: viewModel.quizResultContext.gameType,
                quizDifficulty: viewModel.quizResultContext.quizDifficulty
            )
            nav.goTo(.leaderboard(resultContext))
            
        case .globalRanking:
            // TODO:
            nav.goTo(.globalRanking(viewModel.quizResultContext.gameType, viewModel.currentLevelRaw, viewModel.quizResultContext.quizDifficulty))

        case .home:
            nav.backToRoot()
        }
    }
}


//#Preview {
//    ResultView(quizResultContext.correctAnswers: 2, resultsHistory: [])
//}
