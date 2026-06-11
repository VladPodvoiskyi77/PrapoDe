import Foundation

struct LearningSession {
    let mode: Activity
    var answers: [AnswerResult]
}

struct AnswerResult: Identifiable, Hashable {
    let id = UUID()
    let base: String // слово (глагол/существвительное/прилагательное) с предлогом
    let preposition: String // немецкий прелог
    let prepositionTranslation: String // перевод слова (глагола/существительного/прилагательного) с предлогом
    let example: String
    let exampleTranslation: String
    let caseType: String
    let usersAnswer: String
    var isCorrect: Bool {
        return usersAnswer.isEquivalentIgnoringUmlauts(to: preposition)
    }
}
