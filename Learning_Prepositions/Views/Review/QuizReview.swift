import SwiftUI

struct QuizReviewView: View {
    @StateObject private var viewModel: QuizReviewViewModel
    @State private var prepositionSheetItem: PrepositionDetailSheetItem?

    init(history: [AnswerResult]) {
        _viewModel = StateObject(wrappedValue: QuizReviewViewModel(history: history))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                ScoreHeaderView(viewModel: viewModel)
                    .padding(.top)

                LazyVStack(spacing: 16) {
                    ForEach(viewModel.history) { question in
                        QuizReviewCard(
                            item: question,
                            onOpenPrepositionDetail: { prepositionSheetItem = $0 }
                        )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .background(AppTheme.mainGradient.ignoresSafeArea())
        .navigationTitle(L10n.QuizReview.title)
        .navigationBarTitleDisplayMode(.inline)
        .prepositionDetailSheet(item: $prepositionSheetItem)
    }
}

