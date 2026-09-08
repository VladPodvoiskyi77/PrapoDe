import SwiftUI

struct TrainingCompletionView: View {

    let stats: TrainingSessionStats
    let reviewedCount: Int
    var onFinish: () -> Void

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 30) {

            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .opacity(isAnimating ? 1.0 : 0.0)

                Circle()
                    .fill(Color.yellow.opacity(0.1))
                    .frame(width: 90, height: 90)

                Image(systemName: "trophy.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .scaleEffect(isAnimating ? 1.0 : 0.1)
            }
            .padding(.top, 20)

            VStack(spacing: 12) {
                Text(L10n.Training.Finish.title)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)

                Text(L10n.Training.Finish.reviewed(reviewedCount))
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
                    .padding(.horizontal)

                if stats.markedKnown > 0 {
                    Text(L10n.Training.Finish.progress(
                        stats.scorePointsGained,
                        stats.newlyMastered
                    ))
                    .font(.subheadline.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.orange)
                    .padding(.horizontal)
                }
            }

            MenuCard(
                title: L10n.Result.Button.MainMenu.title,
                iconName: "house.fill",
                iconColor: .red,
                backgroundColor: AnyShapeStyle(AppTheme.linearGradient),
                action: {
                    onFinish()
                }

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
