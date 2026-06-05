import Foundation

final class UserDefaultsQuizResultStorage: QuizResultStorage {
    private let defaults = AppConfig.sharedDefaults
    private let key = AppConfig.Keys.quizResults
    
    func load() -> [QuizResult] {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([QuizResult].self, from: data) else {
            return []
        }
        return decoded
    }
    
    func save(_ results: [QuizResult]) {
        if let encoded = try? JSONEncoder().encode(results) {
            defaults.set(encoded, forKey: key)
        }
    }
    
    func deleteAllResults() {
        defaults.removeObject(forKey: key)
    }
}
