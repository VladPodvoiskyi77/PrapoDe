import Foundation
import Testing
@testable import Learning_prepositions_is_easy

struct LeaderboardManagerTests {
    @Test
    func processNewResult_marksFasterSprintAsNewRecord() {
        let storage = InMemoryQuizResultStorage()
        let manager = LeaderboardManager(storage: storage)

        _ = manager.processNewResult(
            TestFixtures.quizResult(score: 8, timeElapsed: 45, date: Date(timeIntervalSince1970: 100))
        )

        let newRecord = manager.processNewResult(
            TestFixtures.quizResult(score: 8, timeElapsed: 30, date: Date(timeIntervalSince1970: 200))
        )

        let best = LeaderboardRankingLogic.sortSprintResults(storage.results).first

        #expect(newRecord == true)
        #expect(storage.results.count == 2)
        #expect(best?.timeElapsed == 30)
    }

    @Test
    func processNewResult_keepsSeparateSprintGroupsByQuestionCount() {
        let storage = InMemoryQuizResultStorage()
        let manager = LeaderboardManager(storage: storage)

        _ = manager.processNewResult(TestFixtures.quizResult(score: 10, total: 10))
        _ = manager.processNewResult(TestFixtures.quizResult(score: 9, total: 20))

        #expect(storage.results.count == 2)
    }

    @Test
    func processNewResult_keepsTopTenPerGroup() {
        let storage = InMemoryQuizResultStorage()
        let manager = LeaderboardManager(storage: storage)

        for index in 0..<12 {
            _ = manager.processNewResult(
                TestFixtures.quizResult(
                    score: index,
                    date: Date(timeIntervalSince1970: TimeInterval(index))
                )
            )
        }

        #expect(storage.results.count == 10)
        #expect(storage.results.map(\.score).max() == 11)
    }

    @Test
    func processNewResult_quizUsesPercentageNotRawScoreTotalMix() {
        let storage = InMemoryQuizResultStorage()
        let manager = LeaderboardManager(storage: storage)

        _ = manager.processNewResult(
            TestFixtures.quizResult(score: 8, total: 10, gameType: .quiz, date: Date(timeIntervalSince1970: 100))
        )

        let isRecord = manager.processNewResult(
            TestFixtures.quizResult(score: 9, total: 10, gameType: .quiz, date: Date(timeIntervalSince1970: 200))
        )

        let best = LeaderboardRankingLogic.sortStandardResults(
            storage.results.filter { $0.gameType == .quiz }
        ).first

        #expect(isRecord == true)
        #expect(best?.score == 9)
    }
}
