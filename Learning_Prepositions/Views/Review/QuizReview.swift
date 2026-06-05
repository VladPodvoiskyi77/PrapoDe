import SwiftUI

struct QuizReviewView: View {
    @StateObject private var viewModel: QuizReviewViewModel
    
    // Инициализатор принимает массив вопросов
    init(history: [AnswerResult]) {
        _viewModel = StateObject(wrappedValue: QuizReviewViewModel(history: history))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Шапка с графиком
                ScoreHeaderView(viewModel: viewModel)
                    .padding(.top)
                
                // Список карточек с вопросами
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.history) { question in
                        QuizReviewCard(item: question)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .background(AppTheme.mainGradient.ignoresSafeArea())
        .navigationTitle(L10n.QuizReview.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

