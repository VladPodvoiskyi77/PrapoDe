import SwiftUI
import Combine

class WritingViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var userInput: String = ""
    @Published var isCorrect: Bool? = nil
    @Published var showHint: Bool = false
    @Published var hintTitle: String = ""
    @Published var hintMessage: String = ""
    @Published var currentIndex: Int = 0
    @Published var numberOfQuestions: Int = 10
    
    @Published var wordsForTasks: [WordItem] = []
    @Published var otherVariants: [String] = []
    @Published var currentResult: WritingResult? = nil
    @Published var resultsHistory: [AnswerResult] = []
    @Published var correctAnswers: Int = 0
    
    // MARK: - Private Properties
    private var items: [WordItem]
    private let repository: WordRepository
    private let currentCategory: Category
    private let evaluator = GermanResponseEvaluator()
    private let leaderboardManager: LeaderboardManaging
    private var sessionCompleted = false
    
    @AppStorage(AppConfig.Keys.selectedLanguage, store: AppConfig.appGroupStore)
    private var selectedLanguageRawValue = Language.en.rawValue
    @AppStorage(AppConfig.Keys.selectedLevel, store: AppConfig.appGroupStore)
    private var levelRaw = Level.a1.rawValue
    
    // MARK: - Computed Properties
    var currentLanguage: Language { Language(rawValue: selectedLanguageRawValue) ?? .en }
    var selectedLevel: Level { Level(rawValue: levelRaw) ?? .a1 }
    var currentWord: WordItem { wordsForTasks[currentIndex] }
    
    private func translationKey(for word: WordItem) -> String {
        "\(word.translationWordWithPrep(for: currentLanguage))_\(word.caseType.lowercased())"
    }

    init(items: [WordItem], currentCategory: Category, repository: WordRepository = WordRepository(), manager: LeaderboardManaging? = nil) {
        self.items = items
        self.leaderboardManager = manager ?? LeaderboardManager(storage: UserDefaultsQuizResultStorage())
        self.repository = repository
        self.currentCategory = currentCategory
        self.wordsForTasks = items.getWordsForQuiz(count: numberOfQuestions)
    }
    
    // MARK: - Core Logic
    
    func checkAnswer() {
        let input = normalizeForComparison(userInput)
        let targets = allPossibleTargets
        
        guard !input.isEmpty else { return }
        
        let evaluation = evaluator.evaluate(input: input, targets: targets, normalize: normalizeForComparison)
        self.currentResult = evaluation.result
        
        let matchedItem = allPossibleItems.first { normalizeForComparison($0.basePreposition) == input }
        let itemToDisplay = matchedItem ?? currentWord
        
        let resultEntry = AnswerResult(
            base: itemToDisplay.translationWordWithPrep(for: currentLanguage),
            preposition: itemToDisplay.basePreposition,
            prepositionTranslation: itemToDisplay.basePreposition,
            example: itemToDisplay.example,
            exampleTranslation: itemToDisplay.translation(for: currentLanguage),
            caseType: itemToDisplay.caseType,
            usersAnswer: userInput
        )

        resultsHistory.append(resultEntry)
        updateUI(with: evaluation, for: itemToDisplay.id)
    }
    
    private func updateUI(with evaluation: Evaluation, for id: UUID) {
        let result = evaluation.result
        self.isCorrect = (result != .wrong)
        self.hintMessage = (result == .wrong) ? "" : evaluation.matchedTarget
        
        switch result {
        case .perfect, .missingUmlaut, .extraUmlaut:
            hintTitle = result == .perfect ? L10n.Writing.Hint.perfect :
                       (result == .missingUmlaut ? L10n.Writing.Hint.almost : L10n.Writing.Hint.extraUmlaut)
            
            otherVariants = allPossibleTargets.filter { $0 != evaluation.matchedTarget }
            processCorrectAnswer(for: id)
            
        case .wrong:
            hintTitle = L10n.Writing.Hint.error
            otherVariants = allPossibleTargets
            triggerErrorFeedback()
            AnalyticsManager.shared.logWrongAnswer(
                mode: .writing,
                wordWithPrap: currentWord.basePreposition,
                level: selectedLevel.rawValue,
                category: currentCategory.rawValue,
                userAnswer: userInput
            )
        }
        
        withAnimation(.spring()) { showHint = true }
    }
    
    // MARK: - Helpers
    
    private func normalizeForComparison(_ text: String) -> String {
        text.lowercased()
            .replacing(/\b\(sich\)\b|\bsich\b|\bsein\b/, with: "")
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
    
    var allPossibleItems: [WordItem] {
        let currentKey = translationKey(for: currentWord)
        return items.filter { translationKey(for: $0) == currentKey }
    }
    
    var allPossibleTargets: [String] {
        allPossibleItems.map(\.basePreposition)
    }
    
    func getFormattedHint() -> AttributedString {
        guard isCorrect == true, let result = currentResult else {
            return AttributedString(hintMessage)
        }
        
        if result == .missingUmlaut || result == .extraUmlaut {
            return hintMessage.highlightingMissingUmlauts(comparedTo: userInput)
        }
        
        return AttributedString(hintMessage)
    }
    
    // MARK: - Actions
    
    func processTyping(_ newValue: String) {
        if isCorrect != nil {
            resetUIState()
        }
    }
    
    private func resetUIState() {
        isCorrect = nil
        currentResult = nil
        withAnimation { showHint = false }
    }
    
    private func processCorrectAnswer(for id: UUID) {
        correctAnswers += 1
        if let masterIndex = items.firstIndex(where: { $0.id == id }) {
            items[masterIndex].registerCorrectAnswer()
            replaceIdenticalTasks(for: items[masterIndex])
        }
        saveProgressSafely()
    }
    
    private func saveProgressSafely() {
        let itemsToSave = items
        let level = selectedLevel.rawValue
        let category = currentCategory.fileName
        DispatchQueue.global(qos: .utility).async {
            self.repository.saveItems(itemsToSave, level: level, category: category)
        }
    }
    
    private func replaceIdenticalTasks(for answeredWord: WordItem) {
        let currentKey = translationKey(for: answeredWord)
        
        let initialCount = wordsForTasks.count
        wordsForTasks.removeAll(where: { item in
            let index = wordsForTasks.firstIndex(where: { $0.id == item.id }) ?? 0
            return index > currentIndex && translationKey(for: item) == currentKey
        })
        
        let countToRemove = initialCount - wordsForTasks.count
        guard countToRemove > 0 else { return }
        
        let existingIDs = Set(wordsForTasks.map(\.id))
        let existingKeys = Set(wordsForTasks.map { translationKey(for: $0) })
        
        let candidates = items.filter { item in
            !existingIDs.contains(item.id) && !existingKeys.contains(translationKey(for: item))
        }
        
        let newTasks = candidates.shuffled().prefix(countToRemove)
        wordsForTasks.append(contentsOf: newTasks)
    }
    
    func saveResult() {
        sessionCompleted = true
        let result = QuizResult(
            id: UUID(), score: correctAnswers, total: numberOfQuestions,
            levelRaw: selectedLevel.rawValue, date: Date(),
            gameType: .writing, timeElapsed: nil, category: currentCategory.rawValue
        )

        AnalyticsManager.shared.logActivityFinished(
            mode: .writing,
            category: currentCategory.rawValue,
            level: selectedLevel.rawValue,
            score: correctAnswers,
            total: numberOfQuestions
        )

        _ = leaderboardManager.processNewResult(result)
    }
    
    func nextWord() {
        if currentIndex < wordsForTasks.count - 1 {
            currentIndex += 1
            reset()
        }
    }
    
    private func reset() {
        userInput = ""
        resetUIState()
        hintTitle = ""
        hintMessage = ""
    }
    
    private func triggerErrorFeedback() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
    func restartGame() {
        sessionCompleted = false
        wordsForTasks = items.getWordsForQuiz(count: numberOfQuestions)
        currentIndex = 0
        correctAnswers = 0
        resultsHistory.removeAll()
        reset()

        AnalyticsManager.shared.logActivityStarted(
            mode: .writing,
            category: currentCategory.rawValue,
            level: selectedLevel.rawValue
        )
    }

    func logAbandonedIfNeeded() {
        guard !sessionCompleted else { return }
        AnalyticsManager.shared.logActivityAbandoned(
            mode: .writing,
            category: currentCategory.rawValue,
            level: selectedLevel.rawValue,
            answered: resultsHistory.count,
            total: numberOfQuestions
        )
    }
}
