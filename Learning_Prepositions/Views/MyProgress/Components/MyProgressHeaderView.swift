import SwiftUI

// MARK: - Красивая шапка со статистикой
struct MyProgressHeaderView: View {
    let learnedCount: Int
    let totalCount: Int
    let progress: Double
    let level: String
    let category: String
    
    @State private var showProgress = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            // 1. Верхняя часть (без изменений)
            HStack(alignment: .center) {
                Text(category)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Spacer()
                Text(level)
                    .font(.system(size: 60, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.15), radius: 2, x: 2, y: 2)
            }
            
            // 2. Секция Прогресса
            VStack(spacing: 8) {
                
                HStack(spacing: 12) {
                    
                    // Сама полоска
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.black.opacity(0.2))
                                .frame(height: 12)
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.red, .orange, .green],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: showProgress ? (geometry.size.width * progress) : 0, height: 12)
                                .animation(.easeOut(duration: 1.5), value: showProgress)
                        }
                    }
                    .frame(height: 12) // Фиксируем высоту контейнера полоски
                    
                    // 👇 Текст с процентами справа
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 45, alignment: .trailing)
                }
                
                // Подписи снизу
                HStack {
                    Text(L10n.MyProgress.Stats.learned(learnedCount))
                    Spacer()
                    Text(L10n.MyProgress.Stats.total(totalCount))
                        .padding(.trailing, 55)
                }
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(24)
        .background(AppTheme.linearGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: AppTheme.cardShadow.opacity(0.4), radius: 12, x: 0, y: 8)
        
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showProgress = true
            }
        }
        .onDisappear { showProgress = false }
    }
}
