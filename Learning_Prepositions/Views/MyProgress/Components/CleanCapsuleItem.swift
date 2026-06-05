import SwiftUI

struct CleanCapsuleItem: View {
    let preposition: String
    let isSelected: Bool
    let action: () -> Void
    
    // 🔥 ОБНОВЛЕННАЯ ЛОГИКА ИКОНКИ
    var iconString: String {
        // Получаем локализованное слово "Все" для сравнения
        // (Используем тот же ключ, что вы добавили в Localizable.strings)
        let allTitle = L10n.MyProgress.Capsule.All.title
        
        // Если текст совпадает с "Все" (на любом языке) — возвращаем бесконечность
        if preposition == allTitle {
            return "∞"
        }
        
        // Иначе возвращаем первую букву
        return String(preposition.prefix(1)).uppercased()
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                
                // 1. ИКОНКА
                // Используем наше новое свойство iconString
                Text(iconString)
                    // Если это бесконечность, можно сделать шрифт чуть крупнее, чтобы смотрелось красиво
                    .font(.system(size: iconString == "∞" ? 28 : 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(isSelected ? AnyShapeStyle(AppTheme.mainGradient) : AnyShapeStyle(.white))
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(isSelected ? .white.opacity(0.2) : .white.opacity(0.1))
                    )
                    // Немного поднимем бесконечность, она часто визуально "падает"
                    .padding(.bottom, iconString == "∞" ? 2 : 0)
                
                // 2. ТЕКСТ ПРЕДЛОГА (Снизу)
                if isSelected {
                    Text(preposition)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black.opacity(0.8))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .padding(.horizontal, 4)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(width: isSelected ? 85 : 60, height: isSelected ? 130 : 60)
            
            // ФОН КАПСУЛЫ
            .background(
                AppTheme.linearGradient
            )
            .clipShape(Capsule())
            .overlay(
                Capsule().strokeBorder(.white.opacity(isSelected ? 0.8 : 0.3), lineWidth: 1)
            )
        }
        // Плавная анимация
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isSelected)
    }
}
