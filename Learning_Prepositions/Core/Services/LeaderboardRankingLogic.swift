import Foundation

/// Pure ranking rules shared by local leaderboard, global ranking, and Firestore upload.
enum LeaderboardRankingLogic {
    static func filterByCountry(
        _ entries: [GlobalRankingEntry],
        countryCode: String,
        limit: Int
    ) -> [GlobalRankingEntry] {
        let normalizedCode = countryCode.uppercased()
        guard !normalizedCode.isEmpty else { return [] }

        return entries
            .filter { $0.countryCode.uppercased() == normalizedCode }
            .sorted(by: isSprintEntryHigher)
            .prefix(limit)
            .map { $0 }
    }

    static func sortSprintResults(_ results: [QuizResult]) -> [QuizResult] {
        results.sorted(by: isSprintResultHigher)
    }

    static func sortStandardResults(_ results: [QuizResult]) -> [QuizResult] {
        results.sorted(by: isStandardResultHigher)
    }

    private static func isSprintEntryHigher(_ lhs: GlobalRankingEntry, _ rhs: GlobalRankingEntry) -> Bool {
        if lhs.score != rhs.score { return lhs.score > rhs.score }
        return lhs.timeElapsed < rhs.timeElapsed
    }

    private static func isSprintResultHigher(_ lhs: QuizResult, _ rhs: QuizResult) -> Bool {
        if lhs.score != rhs.score { return lhs.score > rhs.score }

        let time1 = lhs.timeElapsed ?? Double.greatestFiniteMagnitude
        let time2 = rhs.timeElapsed ?? Double.greatestFiniteMagnitude
        if time1 != time2 { return time1 < time2 }

        return lhs.date < rhs.date
    }

    private static func isStandardResultHigher(_ lhs: QuizResult, _ rhs: QuizResult) -> Bool {
        if lhs.percentage != rhs.percentage { return lhs.percentage > rhs.percentage }
        return lhs.date < rhs.date
    }
}
