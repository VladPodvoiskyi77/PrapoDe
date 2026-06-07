import Foundation
import Testing
@testable import Learning_prepositions_is_easy

struct LeaderboardRankingLogicTests {
    @Test
    func filterByCountry_keepsOnlyMatchingCountry() {
        let entries = [
            TestFixtures.rankingEntry(userId: "1", countryCode: "UA", score: 9),
            TestFixtures.rankingEntry(userId: "2", countryCode: "DE", score: 10),
            TestFixtures.rankingEntry(userId: "3", countryCode: "ua", score: 8)
        ]

        let filtered = LeaderboardRankingLogic.filterByCountry(entries, countryCode: "UA", limit: 50)

        #expect(filtered.count == 2)
        #expect(filtered.allSatisfy { $0.countryCode.uppercased() == "UA" })
    }

    @Test
    func filterByCountry_sortsByScoreThenTime() {
        let entries = [
            TestFixtures.rankingEntry(userId: "1", countryCode: "DE", score: 8, timeElapsed: 40),
            TestFixtures.rankingEntry(userId: "2", countryCode: "DE", score: 9, timeElapsed: 35),
            TestFixtures.rankingEntry(userId: "3", countryCode: "DE", score: 8, timeElapsed: 25)
        ]

        let filtered = LeaderboardRankingLogic.filterByCountry(entries, countryCode: "DE", limit: 50)

        #expect(filtered.map(\.userId) == ["2", "3", "1"])
    }

    @Test
    func filterByCountry_respectsLimit() {
        let entries = (1...5).map {
            TestFixtures.rankingEntry(userId: "\($0)", countryCode: "AT", score: $0)
        }

        let filtered = LeaderboardRankingLogic.filterByCountry(entries, countryCode: "AT", limit: 3)

        #expect(filtered.count == 3)
        #expect(filtered.first?.score == 5)
    }

    @Test
    func filterByCountry_returnsEmptyForBlankCountryCode() {
        let entries = [
            TestFixtures.rankingEntry(userId: "1", countryCode: "UA", score: 9)
        ]

        let filtered = LeaderboardRankingLogic.filterByCountry(entries, countryCode: " ", limit: 50)

        #expect(filtered.isEmpty)
    }

    @Test
    func sortSprintResults_prefersHigherScoreAndFasterTime() {
        let older = Date(timeIntervalSince1970: 1_000)
        let newer = Date(timeIntervalSince1970: 2_000)

        let results = [
            TestFixtures.quizResult(score: 8, timeElapsed: 40, date: older),
            TestFixtures.quizResult(score: 9, timeElapsed: 30, date: newer),
            TestFixtures.quizResult(score: 8, timeElapsed: 25, date: newer)
        ]

        let sorted = LeaderboardRankingLogic.sortSprintResults(results)

        #expect(sorted.map(\.score) == [9, 8, 8])
        #expect(sorted[1].timeElapsed == 25)
    }

    @Test
    func sortStandardResults_prefersHigherPercentage() {
        let results = [
            TestFixtures.quizResult(score: 7, total: 10, gameType: .quiz),
            TestFixtures.quizResult(score: 9, total: 10, gameType: .quiz),
            TestFixtures.quizResult(score: 8, total: 10, gameType: .quiz)
        ]

        let sorted = LeaderboardRankingLogic.sortStandardResults(results)

        #expect(sorted.map(\.score) == [9, 8, 7])
    }
}
