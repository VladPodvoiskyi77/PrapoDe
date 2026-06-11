import SwiftUI

struct ResultScoreView: View {
    let correctAnswers: Int
    let totalQuestions: Int
    
    @State private var isAnimating = false
    
    private var progress: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions)
    }
    
    private var scoreColor: Color {
        if progress >= 0.8 { return .green }
        if progress >= 0.5 { return .orange }
        return .red
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .foregroundStyle(.tertiary) // Адаптивный светло-серый
                .opacity(0.3)
            
            Circle()
                .trim(from: 0, to: isAnimating ? progress : 0)
                .stroke(
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .foregroundStyle(scoreColor)
                .rotationEffect(.degrees(-90))
                    .shadow(color: scoreColor.opacity(0.3), radius: 8, x: 0, y: 0)
            VStack(spacing: -2) {                
                Text("\(correctAnswers)")
                    .font(.system(size: 80, weight: .heavy, design: .rounded))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())                
                Text(L10n.Result.correctAnswers(correctAnswers))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .frame(width: 130)
                    }
            .offset(y: 5)
            }
        .frame(width: 220, height: 220)
        .padding(.vertical, 20)
        .onAppear {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.7)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ResultScoreView(correctAnswers: 8, totalQuestions: 10)
    }
}

