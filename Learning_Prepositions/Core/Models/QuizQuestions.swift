import Foundation

struct LearningSession {
    let mode: Activity
    var answers: [AnswerResult]
}

struct AnswerResult: Identifiable, Hashable {
    let id = UUID() // Нужно для List/ForEach
    let base: String // слово (глагол/существвительное/прилагательное) с предлогом
    let preposition: String // немецкий прелог
    let prepositionTranslation: String // перевод слова (глагола/существительного/прилагательного) с предлогом
    let example: String // пример предложения с base на немецком
    let exampleTranslation: String //переввод примера предложения с base на немецком
    let caseType: String // Dativ/Akkusativ/Genetiv
    let usersAnswer: String // ответ юзера
    
    // Хелпер, чтобы узнать, правильно ли ответил юзер
    var isCorrect: Bool {
        return usersAnswer.isEquivalentIgnoringUmlauts(to: preposition)
        //return preposition == usersAnswer
    }
}
