import SwiftUI

@MainActor
final class TrainingViewModel: ObservableObject {
    @Published var words: [WordItem] = []

    private let categoryName: String
    private let initialWordCount: Int

    @AppStorage("selectedLevel", store: UserDefaults(suiteName: AppConfig.Constants.appGroupID))
    private var selectedLevelRawValue = Level.a1.rawValue

    private var selectedLevel: Level { Level(rawValue: selectedLevelRawValue) ?? .a1 }

    init(words: [WordItem], category: Category) {
        self.words = words
        self.categoryName = category.rawValue
        self.initialWordCount = words.count
    }

    func logSessionStarted() {
        guard initialWordCount > 0 else { return }

        AnalyticsManager.shared.logActivityStarted(
            mode: .training,
            category: categoryName,
            level: selectedLevel.rawValue
        )
    }

    func logSessionFinished() {
        AnalyticsManager.shared.logActivityFinished(
            mode: .training,
            category: categoryName,
            level: selectedLevel.rawValue,
            score: initialWordCount,
            total: initialWordCount
        )
    }

    func removeTopCard() {
        if !words.isEmpty {
            _ = words.popLast()
        }
    }

    func returnCardToDeck() {
        if var card = words.popLast() {
            card.id = UUID()
            words.insert(card, at: 0)
        }
    }
}
