import SwiftUI

struct TrainingCompletionView: View {
    
    var onFinish: () -> Void
    //var onRestart: () -> Void // Опционально, если захотите добавить кнопку "Повторить"
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 30) {
            
            // 1. Иконка успеха (Кубок с свечением)
            ZStack {
                // Внешнее свечение
                Circle()
                    .fill(Color.yellow.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .opacity(isAnimating ? 1.0 : 0.0)
                
                // Внутренний круг
                Circle()
                    .fill(Color.yellow.opacity(0.1))
                    .frame(width: 90, height: 90)
                
                // Сама иконка
                Image(systemName: "trophy.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .scaleEffect(isAnimating ? 1.0 : 0.1)
            }
            .padding(.top, 20)
            
            // 2. Текстовый блок
            VStack(spacing: 12) {
                Text(L10n.Training.Finish.title)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                
                Text(L10n.Training.Finish.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
                    .padding(.horizontal)
            }
            
            // 3. Кнопка действия
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
        .background(Color.white) // Белая карточка
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 32)
        // Анимация появления
        .scaleEffect(isAnimating ? 1.0 : 0.8)
        .opacity(isAnimating ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                isAnimating = true
            }
        }
    }
}



