import SwiftUI

struct TrainingSessionStats: Equatable {
    var markedKnown: Int = 0
    var scorePointsGained: Int = 0
    var newlyMastered: Int = 0
}

@MainActor
final class TrainingViewModel: ObservableObject {
    static let batchSize = 20

    @Published var words: [WordItem] = []
    @Published private(set) var sessionStats = TrainingSessionStats()
    @Published private(set) var currentBatchSize = 0
    @Published private(set) var remainingCount = 0
    @Published private(set) var showBatchCheckpoint = false
    @Published private(set) var isComplete = false

    private var remainingPool: [WordItem]
    private var offeredCount = 0
    private var fullWordItems: [WordItem]
    private let category: Category
    private let categoryName: String
    private let repository: WordRepository

    var knownInBatch: Int { max(0, currentBatchSize - words.count) }

    private var sessionStarted = false
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
        self.remainingPool = deckWords
        self.category = category
        self.categoryName = category.analyticsName
        self.repository = repository
        if remainingPool.isEmpty {
            isComplete = true
        } else {
            loadNextBatch()
        }
    }

    func logSessionStarted() {
        guard !sessionStarted, offeredCount > 0 else { return }
        sessionStarted = true

        AnalyticsManager.shared.logActivityStarted(
            mode: .training,
            category: categoryName,
            level: selectedLevel.rawValue
        )
    }

    func logSessionFinished() {
        guard !sessionFinished else { return }
        sessionFinished = true
        flushSave()

        AnalyticsManager.shared.logActivityFinished(
            mode: .training,
            category: categoryName,
            level: selectedLevel.rawValue,
            score: sessionStats.markedKnown,
            total: max(offeredCount, sessionStats.markedKnown)
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
            total: max(offeredCount, sessionStats.markedKnown)
        )
    }

    func continueLearning() {
        showBatchCheckpoint = false
        loadNextBatch()
    }

    func finishFromCheckpoint() {
        showBatchCheckpoint = false
        isComplete = true
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
        if words.isEmpty {
            remainingCount = remainingPool.count
            if remainingPool.isEmpty {
                isComplete = true
            } else {
                showBatchCheckpoint = true
            }
        }
        scheduleSave()
    }

    private func loadNextBatch() {
        let take = min(Self.batchSize, remainingPool.count)
        guard take > 0 else {
            isComplete = true
            return
        }
        let batch = Array(remainingPool.suffix(take))
        remainingPool.removeLast(take)
        offeredCount += batch.count
        words = batch
        currentBatchSize = batch.count
        remainingCount = remainingPool.count
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
