import SwiftUI

enum ResultButtonType {
    case review
    case repeatTest
    case leaderboard
    case globalRanking
    case home
    
    var title: String {
        switch self {
        case .review: return L10n.Result.Button.ReviewАnswers.title
        case .repeatTest: return L10n.Result.Button.RepeatTest.title
        case .leaderboard: return L10n.Result.Button.BestResults.title
        case .globalRanking: return L10n.WorldRanking.Sprint.title
        case .home: return L10n.Result.Button.MainMenu.title
        }
    }
    
    var iconName: String {
        switch self {
        case .review: return "doc.text.magnifyingglass"
        case .repeatTest: return "arrow.clockwise"
        case .leaderboard: return "trophy.fill"
        case .globalRanking: return "globe.europe.africa.fill" // Иконка глобуса
        case .home: return "house.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .review: return .blue
        case .repeatTest: return .green
        case .leaderboard: return .orange
        case .globalRanking: return .purple // Фиолетовый для отличия от локального топа
        case .home: return .red
        }
    }
}
