import Foundation

enum RankingPeriod: String, CaseIterable, Identifiable {
    case allTime
    case month
    case week

    var id: String { rawValue }

    func since(now: Date = Date()) -> Date? {
        switch self {
        case .allTime: return nil
        case .month: return now.addingTimeInterval(-30 * 24 * 60 * 60)
        case .week: return now.addingTimeInterval(-7 * 24 * 60 * 60)
        }
    }
}

/// Pure ranking rules shared by local leaderboard, global ranking, and Firestore upload.
enum LeaderboardRankingLogic {
    static func filterByCountry(
        _ entries: [GlobalRankingEntry],
        countryCode: String,
        limit: Int
    ) -> [GlobalRankingEntry] {
        let normalizedCode = countryCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !normalizedCode.isEmpty else { return [] }
        return rank(entries, countryCode: normalizedCode, since: nil, limit: limit)
    }

    static func rank(
        _ entries: [GlobalRankingEntry],
        countryCode: String?,
        since: Date?,
        limit: Int
    ) -> [GlobalRankingEntry] {
        let normalizedCode = countryCode?.uppercased() ?? ""

        return entries
            .filter { entry in
                if !normalizedCode.isEmpty {
                    guard entry.countryCode.uppercased() == normalizedCode else { return false }
                }
                if let since {
                    guard entry.timestamp >= since else { return false }
                }
                return true
            }
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
