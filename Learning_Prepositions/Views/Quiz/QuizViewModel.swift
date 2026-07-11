struct OptionItem: Identifiable {
    let id = UUID()
    let text: String
}

// MARK: - ViewModel
import SwiftUI

@MainActor
final class QuizViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let leaderboardManager: LeaderboardManaging
    private let repository: WordRepository
    let categoryName: String
    
    // MARK: - Settings & Data
    @AppStorage("selectedLanguage", store: UserDefaults(suiteName: AppConfig.Constants.appGroupID))
    private var languageRaw = Language.en.rawValue
    @AppStorage("selectedLevel", store: UserDefaults(suiteName: AppConfig.Constants.appGroupID))
    private var levelRaw = Level.a1.rawValue
    
    private var fullWordItems: [WordItem]
    @Published private(set) var wordItems: [WordItem]
    @Published var resultsHistory: [AnswerResult] = []
    private var candidateWords: [WordItem]
    var totalQuestions: Int
    
    // MARK: - Game State
    @Published var currentIndex: Int = 0
    @Published var stableOptions: [OptionItem] = []
    @Published var selectedAnswer: String?
    @Published var isAnswered = false
    @Published var safeCount: Int = 0
    
    var correctAnswers = 0
    @Published private(set) var isNewRecord = false
    private var sessionCompleted = false
    
    // MARK: - Computed Helpers
    var currentLanguage: Language { Language(rawValue: languageRaw) ?? .en }
    var selectedLevel: Level { Level(rawValue: levelRaw) ?? .a1 }
    
    var currentWord: WordItem {
        guard currentIndex < wordItems.count else { return wordItems.first! }
        return wordItems[currentIndex]
    }
    
    // MARK: - Init
    init(fullWordItems: [WordItem], filteredItem: [WordItem], categoryName: String, manager: LeaderboardManaging? = nil, repository: WordRepository = WordRepository()) {
        self.fullWordItems = fullWordItems
        self.candidateWords = filteredItem
        let limit = AppConfig.sharedDefaults.integer(forKey: AppConfig.Keys.questionCount)
        let questionLimit = limit > 0 ? limit : 10
        self.safeCount = min(questionLimit, filteredItem.count)
        let finalItems = filteredItem.getWordsForQuiz(count: min(questionLimit, filteredItem.count))
        self.wordItems = finalItems
        self.totalQuestions = finalItems.count
        self.categoryName = categoryName
        self.repository = repository
        self.leaderboardManager = manager ?? LeaderboardManager(storage: UserDefaultsQuizResultStorage())
        
        generateOptions()
    }
    
    // MARK: - Game Logic
    
    func generateOptions() {
        guard currentIndex < wordItems.count else { return }
        stableOptions = currentWord.getAnswerOptions().map { OptionItem(text: $0) }
    }
    
    // MARK: - Logic (Ответ и Сохранение)
        
    func selectAnswer(_ answer: String) {
        guard !isAnswered else { return }
        selectedAnswer = answer
        isAnswered = true
        
        let isCorrect = (answer == currentWord.preposition)
        
        if isCorrect {
            correctAnswers += 1
            wordItems[currentIndex].registerCorrectAnswer()
        } else {
            wordItems[currentIndex].registerWrongAnswer()
            AnalyticsManager.shared.logWrongAnswer(
                mode: .quiz,
                wordWithPrap: currentWord.basePreposition,
                level: selectedLevel.rawValue,
                category: categoryName,
                userAnswer: answer
            )
        }
        
        let resultEntry = AnswerResult(
            base: currentWord.basePreposition,
            preposition: currentWord.preposition,
            prepositionTranslation: currentWord.translationWordWithPrep(for: currentLanguage),
            example: currentWord.example,
            exampleTranslation: currentWord.translation(for: currentLanguage),
            caseType: currentWord.caseType,
            usersAnswer: answer
        )
        resultsHistory.append(resultEntry)
        
        saveProgressSafely()
    }
    
    private func saveProgressSafely() {
        let changedWord = wordItems[currentIndex]
        
        if let index = fullWordItems.firstIndex(where: { $0.id == changedWord.id }) {
            fullWordItems[index] = changedWord
        }
        
        if let index = candidateWords.firstIndex(where: { $0.id == changedWord.id }) {
            candidateWords[index] = changedWord
        }

        let itemsToSave = fullWordItems

        let currentCategory = Category(rawValue: categoryName)?.fileName ?? ""
        
        Task.detached(priority: .utility) {
            await self.repository.saveItems(itemsToSave,
                                            level: self.selectedLevel.rawValue,
                                            category: currentCategory)
        }
    }
    
    func nextQuestion() {
        guard currentIndex + 1 < wordItems.count else { return }
        currentIndex += 1
        isAnswered = false
        selectedAnswer = nil
        generateOptions()
    }
    
    func refreshData() {
        AnalyticsManager.shared.logActivityStarted(
            mode: .quiz,
            category: categoryName,
            level: selectedLevel.rawValue
        )
        
        currentIndex = 0
        correctAnswers = 0
        isAnswered = false
        selectedAnswer = nil
        resultsHistory.removeAll()
        sessionCompleted = false
        
        generateOptions()
    }
    
    // MARK: - UI Helpers (Simplified)
    
    func buttonColor(for option: String) -> Color {
        guard isAnswered else { return .white }
        
        if option == currentWord.preposition { return .green.opacity(0.8) }
        if option == selectedAnswer { return .red.opacity(0.8) }
        return .white
    }
    
    func saveResult() {
        sessionCompleted = true
        let result = QuizResult(
            id: UUID(), score: correctAnswers, total: totalQuestions,
            levelRaw: selectedLevel.rawValue, date: Date(),
            gameType: .quiz, timeElapsed: nil, category: categoryName
        )

        AnalyticsManager.shared.logActivityFinished(
            mode: .quiz,
            category: categoryName,
            level: selectedLevel.rawValue,
            score: correctAnswers,
            total: result.total
        )

        wordItems = candidateWords.getWordsForQuiz(count: safeCount)
        totalQuestions = wordItems.count        
        isNewRecord = leaderboardManager.processNewResult(result)
        UserProfileManager.shared.recordCompletedActivity(.quiz)
    }

    func logAbandonedIfNeeded() {
        guard !sessionCompleted else { return }
        AnalyticsManager.shared.logActivityAbandoned(
            mode: .quiz,
            category: categoryName,
            level: selectedLevel.rawValue,
            answered: resultsHistory.count,
            total: totalQuestions
        )
    }
}
