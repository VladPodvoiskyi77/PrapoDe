import SwiftUI

struct MenuCard: View {
    let title: String
    let iconName: String
    let iconColor: Color
    var iconLetter: String? = nil
    var backgroundColor: AnyShapeStyle = AnyShapeStyle(AppTheme.cardBackground)
    var staggerIndex: Int = 0
    var isMenuVisible: Bool = true
    let action: () -> Void

    @State private var iconBounce = false
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 16) {
                Group {
                    if let iconLetter {
                        LetterBadge(letter: iconLetter, accent: iconColor)
                    } else {
                        Image(systemName: iconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                            .foregroundStyle(iconColor)
                            .symbolRenderingMode(.hierarchical)
                            .symbolEffect(.bounce, value: iconBounce)
                    }
                }
                .scaleEffect(iconBounce ? 1.08 : 1.0)
                .animation(.spring(response: 0.35, dampingFraction: 0.55), value: iconBounce)
                
                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(backgroundColor)
                    .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .staggeredMenuAppearance(index: staggerIndex, isVisible: isMenuVisible)
        .onAppear {
            let delay = Double(staggerIndex) * 0.07 + 0.12
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                iconBounce.toggle()
            }
        }
        .onChange(of: isMenuVisible) { _, visible in
            guard visible else { return }
            let delay = Double(staggerIndex) * 0.07 + 0.12
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                iconBounce.toggle()
            }
        }
    }
}

struct LetterBadge: View {
    let letter: String
    let accent: Color

    var body: some View {
        Text(letter)
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundStyle(accent)
            .frame(width: 32, height: 32)
            .background(
                accent.opacity(0.16),
                in: RoundedRectangle(cornerRadius: 8, style: .continuous)
            )
    }
}
