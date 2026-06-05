struct ResultContext: Equatable, Hashable {
    let gameType: GameType
    let quizDifficulty: QuizDifficulty
    
    init(gameType: GameType = .quiz, quizDifficulty: QuizDifficulty = .easy) {
        self.gameType = gameType
        self.quizDifficulty = quizDifficulty
    }
}
