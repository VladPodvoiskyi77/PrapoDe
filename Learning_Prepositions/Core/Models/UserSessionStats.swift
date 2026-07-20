import Foundation

struct UserSessionStats: Codable, Equatable {
    var quiz: Int = 0
    var training: Int = 0
    var sprint: Int = 0
    var writing: Int = 0

    var totalCompleted: Int {
        quiz + training + sprint + writing
    }

    mutating func recordCompletion(for activity: Activity) {
        switch activity {
        case .quiz: quiz += 1
        case .training: training += 1
        case .sprint: sprint += 1
        case .writing: writing += 1
        case .myProgress: return
        }
    }

    func count(for activity: Activity) -> Int {
        switch activity {
        case .quiz: return quiz
        case .training: return training
        case .sprint: return sprint
        case .writing: return writing
        case .myProgress: return 0
        }
    }
}
