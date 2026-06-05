import SwiftUI

enum QuizGrade {
    case perfect
    case excellent
    case good
    case needsImprovement
    case tryAgain
    
    // Единое место, где мы определяем пороги оценок (Magic Numbers спрятаны здесь)
    init(percentage: Int) {
        switch percentage {
        case 100:       self = .perfect
        case 80..<100:  self = .excellent
        case 50..<80:   self = .good
        case 1..<50:    self = .needsImprovement
        default:        self = .tryAgain
        }
    }
    
    var title: String {
        switch self {
        case .perfect:          return L10n.QuizReview.Feedback.Title.perfect
        case .excellent:        return L10n.QuizReview.Feedback.Title.excellent
        case .good:             return L10n.QuizReview.Feedback.Title.good
        case .needsImprovement: return L10n.QuizReview.Feedback.Title.needsImprovement
        case .tryAgain:         return L10n.QuizReview.Feedback.Title.tryAgain
        }
    }
    
    var subtitle: String {
        switch self {
        case .perfect:
            return L10n.QuizReview.Feedback.Subtitle.perfect
        default:
            return L10n.QuizReview.Feedback.Subtitle.default
        }
    }
    
    var color: Color {
        switch self {
        case .perfect, .excellent:  return .green
        case .good:                 return .orange
        case .needsImprovement, .tryAgain: return .red
        }
    }
}
