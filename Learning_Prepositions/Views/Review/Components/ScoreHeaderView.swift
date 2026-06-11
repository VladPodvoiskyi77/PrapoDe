import SwiftUI

// MARK: - Компонент: Шапка с круговым графиком
struct ScoreHeaderView: View {
    @ObservedObject var viewModel: QuizReviewViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text(viewModel.feedbackTitle)
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
            
            HStack(spacing: 30) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.15), lineWidth: 12)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(viewModel.accuracyPercent) / 100)
                        .stroke(viewModel.scoreColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 1.0), value: viewModel.accuracyPercent)
                    
                    VStack(spacing: 0) {
                        Text("\(viewModel.accuracyPercent)%")
                            .font(.system(.title2, design: .rounded))
                            .bold()
                            .foregroundColor(.primary)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .padding(10)
                    }
                }
                .frame(width: 90, height: 90)
                
                VStack(alignment: .leading, spacing: 8) {
                    Label(L10n.QuizReview.correctCountFormatted(viewModel.correctCount), systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    
                    Label(L10n.QuizReview.mistakesCountFormatted(viewModel.wrongCount), systemImage: "xmark.circle.fill")
                        .foregroundColor(.red)
                    
                    Text(L10n.QuizReview.totalQuestions + " \(viewModel.totalCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .font(.subheadline)
                .fontWeight(.medium)
            }
            
            Text(viewModel.feedbackSubtitle)
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
