import SwiftUI

enum Activity: String, CaseIterable, Identifiable {
    case training
    case quiz
    case timedQuiz
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .training: return "Обучение"
        case .quiz: return "Квиз"
        case .timedQuiz: return "Квиз на время"
        }
    }
    
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

