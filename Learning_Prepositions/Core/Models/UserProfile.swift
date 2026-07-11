import SwiftUI

struct UserProfile: Codable {
    let id: String
    var name: String
    var country: String
    var totalGamesPlayed: Int
    var completedQuizzes: Int
    var completedTrainings: Int
    var completedSprints: Int
    var bestSprintScore: Int
    let createdAt: Date
}
