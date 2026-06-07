import Foundation

struct GlobalRankingEntry: Identifiable, Codable, Equatable {
    var id: String?
    let userId: String
    let userName: String
    let countryCode: String

    let score: Int
    let total: Int
    let gameType: String
    let level: String
    let category: String
    let timeElapsed: Double
    let timestamp: Date

    var formattedTime: String {
        String(format: "%.2f", timeElapsed)
    }

    var countryFlag: String {
        Self.flagEmoji(for: countryCode)
    }

    static func flagEmoji(for countryCode: String) -> String {
        countryCode.uppercased().unicodeScalars.reduce("") { res, scalar in
            guard let flagScalar = UnicodeScalar(127397 + scalar.value) else { return res }
            return res + String(flagScalar)
        }
    }
}
