import SwiftUI

struct GlobalRecord: Codable {
    let userId: String
    let userName: String
    let countryCode: String
    
    let score: Int
    let total: Int
    let levelRaw: String
    let gameType: String
    let timeElapsed: Double
    let category: String
    
    let timestamp: Date
    let deviceModel: String
    
}
