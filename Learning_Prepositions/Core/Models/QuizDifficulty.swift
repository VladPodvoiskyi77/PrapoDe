import SwiftUI

enum QuizDifficulty: String, CaseIterable, Identifiable {
    case easy
    case medium
    case hard
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .easy: return L10n.СhooseQuizLevel.Level.light
        case .medium: return L10n.СhooseQuizLevel.Level.medium
        case .hard: return L10n.СhooseQuizLevel.Level.heavy
        }
    }
    
    // Количество вопросов в раунде
    var questionCount: Int {
        switch self {
        case .easy: return 10
        case .medium: return 20
        case .hard: return 30
        }
    }
    
    var iconName: String {
        switch self {
        case .easy: return "bicycle"
        case .medium: return "car"
        case .hard: return "airplane"
        }
    }
        
    var iconColor: Color {
        switch self {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    
//    var emoji: String {
//        switch self {
//        case .easy: return "☕️" // На расслабоне
//        case .medium: return "🔥" // Жарко
//        case .hard: return "🚀" // Космос / Хардкор
//        }
//    }
    
    var label: String {
        "\(title)" + " (" + "\(questionCount)" + " \(L10n.СhooseQuizLevel.numberOfQuestions)"+")"
    }
}
