import Foundation
@testable import Learning_prepositions_is_easy

enum TestFixtures {
    static func quizResult(
        score: Int,
        total: Int = 10,
        levelRaw: String = "B1",
        gameType: GameType = .sprint,
        timeElapsed: TimeInterval? = nil,
        date: Date = Date(),
        category: String = Category.verben.rawValue
    ) -> QuizResult {
        QuizResult(
            score: score,
            total: total,
            levelRaw: levelRaw,
            date: date,
            gameType: gameType,
            timeElapsed: timeElapsed,
            category: category
        )
    }

    static func rankingEntry(
        userId: String,
        countryCode: String,
        score: Int,
        total: Int = 10,
        timeElapsed: Double = 30,
        userName: String = "Player",
        timestamp: Date = Date()
    ) -> GlobalRankingEntry {
        GlobalRankingEntry(
            id: userId,
            userId: userId,
            userName: userName,
            countryCode: countryCode,
            score: score,
            total: total,
            gameType: GameType.sprint.rawValue,
            level: "B1",
            category: Category.verben.rawValue,
            timeElapsed: timeElapsed,
            timestamp: timestamp
        )
    }

    static func wordItem(base: String, preposition: String, example: String) throws -> WordItem {
        let json = """
        {
          "base": "\(base)",
          "preposition": "\(preposition)",
          "translationRu": "перевод",
          "translationUa": "переклад",
          "translationEn": "translation",
          "caseType": "Dativ",
          "example": "\(example)",
          "exampleRu": "пример",
          "exampleUa": "приклад",
          "exampleEn": "example"
        }
        """
        return try JSONDecoder().decode(WordItem.self, from: Data(json.utf8))
    }
}

final class InMemoryQuizResultStorage: QuizResultStorage {
    private(set) var results: [QuizResult] = []

    func load() -> [QuizResult] {
        results
    }

    func save(_ results: [QuizResult]) {
        self.results = results
    }
}
