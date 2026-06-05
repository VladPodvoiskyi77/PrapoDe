import SwiftUI
import FirebaseFirestore

struct GlobalRankingEntry: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let userName: String
    let countryCode: String // Должно быть как в консоли Firebase
    
    let score: Int
    let total: Int          // На скрине 'total', проверь чтобы в модели не было 'totalQuestions'
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
