import SwiftUI

enum Activity: String, CaseIterable, Identifiable {
    case myProgress
    case training
    case quiz
    case sprint
    case writing
    
    // Нужно для ForEach
    var id: String { self.rawValue }
    
    // Заголовок для UI
    var title: String {
        switch self {
        case .myProgress: return L10n.UniversalMenu.Activity.Progress.title
        case .training: return L10n.UniversalMenu.Activity.Training.title
        case .writing: return L10n.UniversalMenu.Activity.Writing.title
        case .quiz: return L10n.UniversalMenu.Activity.Quiz.title
        case .sprint: return L10n.UniversalMenu.Activity.Sprint.title
        }
    }
    
    // Цвет темы (опционально)
    var iconName: String {
        switch self {
        case .myProgress: return "chart.line.uptrend.xyaxis"
        case .training: return "book.fill"
        case .quiz: return "checkmark.circle.fill"
        case .sprint: return "timer"
        case .writing: return "square.and.pencil"
        }
    }
}

