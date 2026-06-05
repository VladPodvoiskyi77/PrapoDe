import SwiftUI

final class QuizReviewViewModel: ObservableObject {
    
    // MARK: - Dependencies (Входящие данные)
    let history: [AnswerResult]
    
    init(history: [AnswerResult]) {
        self.history = history
    }
    
    // MARK: - Computed Statistics
    
    var totalCount: Int {
        history.count
    }
    
    var correctCount: Int {
        history.filter { $0.isCorrect }.count
    }
    
    var wrongCount: Int {
        totalCount - correctCount
    }
    
    var accuracyPercent: Int {
        guard totalCount > 0 else { return 0 }
        return Int((Double(correctCount) / Double(totalCount)) * 100)
    }
    
    // MARK: - Grade Logic (Оценка результата)
    
    // Приватное свойство, вычисляющее текущий грейд
    private var grade: QuizGrade {
        QuizGrade(percentage: accuracyPercent)
    }
    
    // MARK: - Presentation Data (Данные для UI)
    
    // ViewModel просто проксирует данные из Grade.
    // Если захотим поменять тексты — меняем их в Enum, не трогая ViewModel.
    var feedbackTitle: String {
        grade.title
    }
    
    var feedbackSubtitle: String {
        grade.subtitle
    }
    
    var scoreColor: Color {
        grade.color
    }
}
