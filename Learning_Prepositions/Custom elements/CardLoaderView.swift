import SwiftUI

struct CardLoaderView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Подложка
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .frame(width: 80, height: 80)
            
            // Маленькая карточка
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: 40, height: 50)
                .shadow(color: .purple.opacity(0.5), radius: 5)
                // 3D Вращение
                .rotation3DEffect(
                    .degrees(isAnimating ? 360 : 0),
                    axis: (x: 0, y: 1, z: 0) // Вращение вокруг вертикальной оси
                )
                .animation(
                    Animation.easeInOut(duration: 1.2)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
        }
        .onAppear {
            isAnimating = true
        }
    }
}
