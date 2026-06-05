import SwiftUI

struct MenuCard: View {
    let title: String
    let iconName: String
    let iconColor: Color
    var backgroundColor: AnyShapeStyle = AnyShapeStyle(AppTheme.cardBackground)
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Иконка
                Image(systemName: iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .foregroundStyle(iconColor)
                    .symbolRenderingMode(.hierarchical)
                
                // Текст
                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(1.0)
                
                Spacer()
                
                // Шеврон
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(backgroundColor)
                    // Тень чуть мягче, чтобы карта не "летала" слишком высоко
                    .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
