import SwiftUI

enum Activity: String, CaseIterable, Identifiable {
    case training
    case quiz
    case timedQuiz
    
    // Нужно для ForEach
    var id: String { self.rawValue }
    
    // Заголовок для UI
    var title: String {
        switch self {
        case .training: return "Обучение" // или "Lernen"
        case .quiz: return "Квиз" // или "Quiz"
        case .timedQuiz: return "Квиз на время"
        }
    }
    
    // Цвет темы (опционально)
    var iconName: String {
        switch self {
        case .training:
            return "book.fill"
        case .quiz:
            return "checkmark.circle.fill"
        case .timedQuiz:
            return "timer"
        }
    }
}

