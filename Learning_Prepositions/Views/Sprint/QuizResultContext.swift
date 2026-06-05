struct QuizResultContext: Equatable, Hashable {
    let correctAnswers: Int
    let isNewRecord: Bool = false
    var resultsHistory: [AnswerResult] = []
    var quizDifficulty: QuizDifficulty = .easy
    var gameType: GameType
    var numberOfQuestions: Int
}

