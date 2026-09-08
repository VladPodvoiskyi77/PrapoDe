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
    func rank_filtersByPeriodAndKeepsScoreOrder() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let entries = [
            TestFixtures.rankingEntry(userId: "week", countryCode: "DE", score: 8, timestamp: now.addingTimeInterval(-3 * 24 * 60 * 60)),
            TestFixtures.rankingEntry(userId: "month", countryCode: "DE", score: 10, timestamp: now.addingTimeInterval(-15 * 24 * 60 * 60)),
            TestFixtures.rankingEntry(userId: "old", countryCode: "DE", score: 12, timestamp: now.addingTimeInterval(-60 * 24 * 60 * 60))
        ]

        let week = LeaderboardRankingLogic.rank(
            entries,
            countryCode: nil,
            since: RankingPeriod.week.since(now: now),
            limit: 100
        )
        #expect(week.map(\.userId) == ["week"])

        let month = LeaderboardRankingLogic.rank(
            entries,
            countryCode: nil,
            since: RankingPeriod.month.since(now: now),
            limit: 100
        )
        #expect(month.map(\.userId) == ["month", "week"])

        let allTime = LeaderboardRankingLogic.rank(
            entries,
            countryCode: nil,
            since: RankingPeriod.allTime.since(now: now),
            limit: 100
        )
        #expect(allTime.map(\.userId) == ["old", "month", "week"])
    }

    @Test
    func rank_combinesCountryAndPeriod() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let recent = now.addingTimeInterval(-2 * 24 * 60 * 60)
        let entries = [
            TestFixtures.rankingEntry(userId: "ua-recent", countryCode: "UA", score: 7, timestamp: recent),
            TestFixtures.rankingEntry(userId: "de-recent", countryCode: "DE", score: 9, timestamp: recent),
            TestFixtures.rankingEntry(userId: "ua-old", countryCode: "UA", score: 11, timestamp: now.addingTimeInterval(-40 * 24 * 60 * 60))
        ]

        let ranked = LeaderboardRankingLogic.rank(
            entries,
            countryCode: "UA",
            since: RankingPeriod.month.since(now: now),
            limit: 100
        )

        #expect(ranked.map(\.userId) == ["ua-recent"])
    }

    @Test
    func rank_respectsLimitOf100() {
        let entries = (1...120).map {
            TestFixtures.rankingEntry(userId: "\($0)", countryCode: "DE", score: $0)
        }

        let ranked = LeaderboardRankingLogic.rank(
            entries,
            countryCode: nil,
            since: nil,
            limit: 100
        )

        #expect(ranked.count == 100)
        #expect(ranked.first?.score == 120)
        #expect(ranked.last?.score == 21)
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
