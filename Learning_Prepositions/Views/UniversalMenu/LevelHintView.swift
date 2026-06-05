import SwiftUI

struct LevelHintView: View {
    var onClose: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .trailing, spacing: -1) {
            
            PopoverArrow()
                .fill(Color.white)
                .frame(width: 20, height: 12)
                .padding(.trailing, 18)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: -2)
                .zIndex(1)
            
            HStack(alignment: .top, spacing: 14) {
                
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Текст
                VStack(alignment: .leading, spacing: 6) {
                    Text(L10n.UniversalMenu.Category.Hint.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.black.opacity(0.85))
                    
                    Text(L10n.UniversalMenu.Category.Hint.description)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.black.opacity(0.6))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)
                }
                
                // Кнопка закрытия
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.gray.opacity(0.5))
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                .padding(.leading, 4)
            }
            .padding(16)
            .background(
                Color.white
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
            )
        }
        .frame(width: 300)
        .scaleEffect(isAnimating ? 1 : 0.8)
        .opacity(isAnimating ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                isAnimating = true
            }
        }
    }
}

struct PopoverArrow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Рисуем треугольник
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY)) // Левый нижний
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY)) // Вершина
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // Правый нижний
        path.closeSubpath()
        return path
    }
}
