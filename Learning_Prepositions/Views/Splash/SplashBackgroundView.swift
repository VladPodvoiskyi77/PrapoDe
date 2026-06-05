import SwiftUI

struct SplashBackgroundView: View {
    private let prepositions = [
        "aus", "außer", "bei", "mit", "nach", "seit", "von", "zu", "gegenüber",
        "bis", "durch", "für", "gegen", "ohne", "um",
        "an", "auf", "hinter", "in", "neben", "über", "unter", "vor", "zwischen",
        "anstatt", "statt", "innerhalb", "trotz", "während", "wegen"
    ]
    
    private let columns = 6
    private let rows = 12
    
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.98, blue: 0.99).ignoresSafeArea()
            
            GeometryReader { proxy in
                let cellWidth = proxy.size.width / CGFloat(columns)
                let cellHeight = proxy.size.height / CGFloat(rows)
                
                ForEach(0..<rows, id: \.self) { row in
                    ForEach(0..<columns, id: \.self) { col in
                        // Оптимизация: вычисляем позицию
                        let xPosition = (CGFloat(col) * cellWidth) + (cellWidth / 2)
                        let yPosition = (CGFloat(row) * cellHeight) + (cellHeight / 2)
                        
                        Text(prepositions.randomElement() ?? "mit")
                            .font(.system(size: CGFloat.random(in: 16...28), weight: .bold, design: .rounded))
                            .foregroundColor(randomColor())
                            .rotationEffect(.degrees(Double.random(in: -20...20)))
                            .position(
                                x: xPosition + CGFloat.random(in: -10...10),
                                y: yPosition + CGFloat.random(in: -10...10)
                            )
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private func randomColor() -> Color {
        [Color.blue, Color.purple, Color.orange, Color.mint]
            .randomElement()?
            .opacity(0.15) ?? .gray.opacity(0.15)
    }
}
