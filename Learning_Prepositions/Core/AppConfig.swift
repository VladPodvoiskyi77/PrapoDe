import Foundation

enum AppConfig {
    enum Support {
        static let appName = "PrapoDe"
        static let email = "appentwickler2025@gmail.com"
    }

    enum Constants {
        static let appGroupID = "group.com.vladpodvoiskyi.prapode"
        static let widgetJsonPath = "data/widget/verben.json"
        static let topScores = 50
    }

    enum Keys {
        static let questionCount = "questionCount"
        static let quizResults = "quizResults"
        static let hasShownLevelHint = "hasShownLevelHint"
        static let lastReviewRequestDate = "lastReviewRequestDate"
        static let selectedLanguage = "selectedLanguage"
        static let selectedLevel = "selectedLevel"
    }

    static let appGroupStore: UserDefaults = {
        UserDefaults(suiteName: Constants.appGroupID) ?? .standard
    }()

    static var sharedDefaults: UserDefaults { appGroupStore }

    /// Moves legacy values from standard UserDefaults into the App Group once.
    static func migrateLegacyUserDefaultsIfNeeded() {
        let group = sharedDefaults
        let standard = UserDefaults.standard

        if group.object(forKey: Keys.questionCount) == nil,
           let value = standard.object(forKey: Keys.questionCount) {
            group.set(value, forKey: Keys.questionCount)
        } else if group.object(forKey: Keys.questionCount) == nil {
            group.set(10, forKey: Keys.questionCount)
        }

        if group.data(forKey: Keys.quizResults) == nil,
           let legacyResults = standard.data(forKey: Keys.quizResults) {
            group.set(legacyResults, forKey: Keys.quizResults)
            standard.removeObject(forKey: Keys.quizResults)
        }

        if group.object(forKey: Keys.hasShownLevelHint) == nil,
           standard.object(forKey: Keys.hasShownLevelHint) != nil {
            group.set(standard.bool(forKey: Keys.hasShownLevelHint), forKey: Keys.hasShownLevelHint)
            standard.removeObject(forKey: Keys.hasShownLevelHint)
        }
    }
}
