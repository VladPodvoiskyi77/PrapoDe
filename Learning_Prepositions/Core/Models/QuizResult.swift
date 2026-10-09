import Foundation

enum GameType: String, Codable, CaseIterable, Identifiable {
    case quiz
    case sprint
    case writing
    case guessCase
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .quiz:
            return L10n.Leaderboard.Picker.Quiz.title
        case .sprint:
            return L10n.Leaderboard.Picker.Sprint.title
        case .writing:
            return L10n.Leaderboard.Picker.Writing.title
        case .guessCase:
            return L10n.Leaderboard.Picker.GuessCase.title
        }
    }
}

struct QuizResult: Identifiable, Equatable, Codable {
    var id: UUID = UUID()
    
    let score: Int
    let total: Int
    let levelRaw: String
    let date: Date
    
    var gameType: GameType
    var timeElapsed: TimeInterval? = nil
    
    var category: String
    
    var percentage: Int {
        guard total > 0 else { return 0 }
        return score * 100 / total
    }
}
