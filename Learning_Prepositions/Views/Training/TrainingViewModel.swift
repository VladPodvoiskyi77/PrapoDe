import SwiftUI

struct TrainingSessionStats: Equatable {
    var markedKnown: Int = 0
    var scorePointsGained: Int = 0
    var newlyMastered: Int = 0
}

@MainActor
final class TrainingViewModel: ObservableObject {
    @Published var words: [WordItem] = []
    @Published private(set) var sessionStats = TrainingSessionStats()

    private var fullWordItems: [WordItem]
    private let category: Category
    private let categoryName: String
    private let initialWordCount: Int
    private let repository: WordRepository

    var initialDeckWordCount: Int { initialWordCount }

    private var sessionFinished = false
    private var saveTask: Task<Void, Never>?

    @AppStorage("selectedLevel", store: UserDefaults(suiteName: AppConfig.Constants.appGroupID))
    private var selectedLevelRawValue = Level.a1.rawValue

    private var selectedLevel: Level { Level(rawValue: selectedLevelRawValue) ?? .a1 }

    init(
        allWords: [WordItem],
        deckWords: [WordItem],
        category: Category,
        repository: WordRepository = WordRepository()
    ) {
        self.fullWordItems = allWords
        self.words = deckWords
        self.category = category
        self.categoryName = category.analyticsName
        self.initialWordCount = deckWords.count
        self.repository = repository
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
        sessionFinished = true
        flushSave()

        AnalyticsManager.shared.logActivityFinished(
            mode: .training,
            category: categoryName,
            level: selectedLevel.rawValue,
            score: sessionStats.markedKnown,
            total: initialWordCount
        )
        UserProfileManager.shared.recordCompletedActivity(.training)
    }

    func logAbandonedIfNeeded() {
        guard !sessionFinished else { return }
        flushSave()

        AnalyticsManager.shared.logActivityAbandoned(
            mode: .training,
            category: categoryName,
            level: selectedLevel.rawValue,
            answered: sessionStats.markedKnown,
            total: initialWordCount
        )
    }

    func markKnown() {
        guard var card = words.popLast() else { return }

        let previousScore = card.learningScore
        let wasLearned = card.isLearned

        card.registerCorrectAnswer()
        mergeIntoFullList(card)

        sessionStats.markedKnown += 1
        sessionStats.scorePointsGained += max(0, card.learningScore - previousScore)
        if !wasLearned && card.isLearned {
            sessionStats.newlyMastered += 1
        }

        HapticFeedback.success()
        scheduleSave()
    }

    func markRepeat() {
        guard var card = words.popLast() else { return }
        card.id = UUID()
        words.insert(card, at: 0)
    }

    func flushSave() {
        saveTask?.cancel()
        saveTask = nil

        let itemsToSave = fullWordItems
        let level = selectedLevel.rawValue
        let categoryFileName = category.fileName
        let repo = repository

        Task.detached(priority: .utility) {
            repo.saveItems(itemsToSave, level: level, category: categoryFileName)
        }
    }

    private func mergeIntoFullList(_ word: WordItem) {
        if let index = fullWordItems.firstIndex(where: { $0.id == word.id }) {
            fullWordItems[index] = word
            return
        }

        if let index = fullWordItems.firstIndex(where: {
            $0.base == word.base && $0.preposition == word.preposition
        }) {
            fullWordItems[index] = word
        }
    }

    private func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            guard !Task.isCancelled else { return }
            flushSave()
        }
    }
}
