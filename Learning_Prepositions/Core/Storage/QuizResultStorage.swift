protocol QuizResultStorage {
    func load() -> [QuizResult]
    func save(_ results: [QuizResult])
    //func deleteAllResults()
}

