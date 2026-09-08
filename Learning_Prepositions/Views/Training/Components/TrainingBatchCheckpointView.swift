import SwiftUI

struct TrainingBatchCheckpointView: View {
    let reviewedInBatch: Int
    let remainingCount: Int
    var onContinue: () -> Void
    var onFinish: () -> Void

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text(L10n.Training.Batch.Checkpoint.title)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                    .multilineTextAlignment(.center)

                Text(L10n.Training.Batch.Checkpoint.message(reviewedInBatch, remainingCount))
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
                    .padding(.horizontal)
            }

            MenuCard(
                title: L10n.Training.Batch.Checkpoint.`continue`,
                iconName: "play.fill",
                iconColor: .teal,
                backgroundColor: AnyShapeStyle(AppTheme.linearGradient),
                action: onContinue
            )

            MenuCard(
                title: L10n.Training.Batch.Checkpoint.finish,
                iconName: "flag.fill",
                iconColor: .orange,
                backgroundColor: AnyShapeStyle(AppTheme.linearGradient),
                action: onFinish
            )
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 32)
        .scaleEffect(isAnimating ? 1.0 : 0.8)
        .opacity(isAnimating ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                isAnimating = true
            }
        }
    }
}
