import SwiftUI

struct GlobalRecord: Codable {
    // Данные пользователя
    let userId: String
    let userName: String
    let countryCode: String
    
    // Данные из QuizResult
    let score: Int
    let total: Int
    let levelRaw: String
    let gameType: String
    let timeElapsed: Double
    let category: String
    
    // Метаданные
    let timestamp: Date
    let deviceModel: String
    
//    var efficiencyScore: Double {
//        guard timeElapsed > 0 else { return 0 }
//        return Double(correctAnswers) / timeElapsed
//    }
}
