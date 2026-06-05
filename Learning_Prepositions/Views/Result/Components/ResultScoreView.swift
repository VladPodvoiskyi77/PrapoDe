import SwiftUI

struct ResultScoreView: View {
    let correctAnswers: Int
    let totalQuestions: Int
    
    @State private var isAnimating = false
    
    // Безопасный расчет прогресса
    private var progress: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions)
    }
    
    // Цвет зависит от результата
    private var scoreColor: Color {
        if progress >= 0.8 { return .green }
        if progress >= 0.5 { return .orange }
        return .red
    }
    
    var body: some View {
        ZStack {
            // 1. ФОНОВЫЙ КРУГ (Трек)
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .foregroundStyle(.tertiary) // Адаптивный светло-серый
                .opacity(0.3)
            
            // 2. АКТИВНЫЙ КРУГ (Прогресс)
            Circle()
                .trim(from: 0, to: isAnimating ? progress : 0)
                .stroke(
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .foregroundStyle(scoreColor)
                .rotationEffect(.degrees(-90)) // Начало сверху
                .shadow(color: scoreColor.opacity(0.3), radius: 8, x: 0, y: 0) // Свечение
            
            // 3. КОНТЕНТ В ЦЕНТРЕ
            VStack(spacing: -2) { // Отрицательный отступ "прижимает" текст к цифре
                
                // БОЛЬШАЯ ЦИФРА (Всегда показывается корректно)
                Text("\(correctAnswers)")
                    .font(.system(size: 80, weight: .heavy, design: .rounded))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText()) // Анимация смены цифр
                
                // ПОДПИСЬ (Ваш локализованный текст)
                Text(L10n.Result.correctAnswers(correctAnswers))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary) // Делаем серым, чтобы не спорил с цифрой
                    .multilineTextAlignment(.center)
                    .lineLimit(2)            // Максимум 2 строки
                    .minimumScaleFactor(0.7) // Уменьшаем шрифт, если текст длинный
                    .frame(width: 130)       // Ограничиваем ширину, чтобы текст был внутри круга
            }
            .offset(y: 5) // Оптическое выравнивание (чуть сдвигаем вниз, так как цифра большая)
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

// Превью для теста
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ResultScoreView(correctAnswers: 8, totalQuestions: 10)
    }
}

