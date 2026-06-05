import SwiftUI


struct AppTheme {
    static let cardBackground = Color(UIColor.secondarySystemGroupedBackground)
    static let cardShadow = Color.black.opacity(0.1) // Чуть усилил, чтобы было видно
    static let primaryText = Color.primary.opacity(0.9)
    
    static var mainGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color("GradientStart"),
                Color("GradientEnd")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var linearGradient: LinearGradient {
        LinearGradient(
            colors: [Color.blue, Color.purple], // Эти цвета ок и для ночи, и для дня
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
