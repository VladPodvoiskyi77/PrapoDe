import SwiftUI
import Combine

@MainActor
final class SpeedQuizViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let repository: WordRepository
    private let leaderboardManager: LeaderboardManaging
    
    let difficulty: QuizDifficulty
    let categoryName: String
    
    // MARK: - Data
    private var fullWordItems: [WordItem]
    private var gameQuestions: [WordItem] = []
    
    // MARK: - Game State
    let totalTime: TimeInterval = 60
    @Published var timeRemaining: TimeInterval = 60
    @Published var currentIndex: Int = 0
    @Published var isGameFinished = false
    @Published var countdownValue: Int = 3
    @Published var isCountingDown = true
    
    @Published var currentWord: WordItem?
    @Published var options: [String] = []
    
    // MARK: - Scoring
    @Published var correctAnswers: Int = 0
    @Published private(set) var isNewRecord = false
    @Published var resultsHistory: [AnswerResult] = []
    @Published var feedbackColor: Color = .clear
    
    private var startDate: Date?
    private var accumulatedTime: TimeInterval = 0
    private var timer: AnyCancellable?
    private var finalCapturedTime: TimeInterval = 0
    private var sessionCompleted = false
    
    @AppStorage("selectedLanguage", store: UserDefaults(suiteName: AppConfig.Constants.appGroupID))
    private var selectedLanguageRawValue = Language.en.rawValue
    @AppStorage("selectedLevel", store: UserDefaults(suiteName: AppConfig.Constants.appGroupID))
    private var selectedLevelRawValue = Level.a1.rawValue
    
    var currentLanguage: Language { Language(rawValue: selectedLanguageRawValue) ?? .ru }
    var selectedLevel: Level { Level(rawValue: selectedLevelRawValue) ?? .a1 }
    
    var timeElapsed: TimeInterval {
        if let start = startDate {
            return accumulatedTime + Date().timeIntervalSince(start)
        }
        return accumulatedTime
    }
    
    init(items: [WordItem], categoryName: String, difficulty: QuizDifficulty, repository: WordRepository = WordRepository(), manager: LeaderboardManaging? = nil) {
        self.fullWordItems = items
        self.categoryName = categoryName
        self.difficulty = difficulty
        self.repository = repository
        self.leaderboardManager = manager ?? LeaderboardManager(storage: UserDefaultsQuizResultStorage())
    }
    
    // MARK: - Game Logic
    
    func restartGame() {
        sessionCompleted = false
        stopGame()
        currentIndex = 0
        correctAnswers = 0
        accumulatedTime = 0
        timeRemaining = totalTime
        isGameFinished = false
        feedbackColor = .clear
        resultsHistory.removeAll()
        
        guard !fullWordItems.isEmpty else { return }
        
        let targetCount = difficulty.questionCount
        self.gameQuestions = fullWordItems.getWordsForQuiz(count: targetCount)
        
        if let first = gameQuestions.first {
            self.currentWord = first
            self.options = PrepositionQuiz.generateOptions(correct: first.preposition)
        }
        
        startGame()
        AnalyticsManager.shared.logActivityStarted(
            mode: .sprint,
            category: categoryName,
            level: selectedLevel.rawValue
        )
    }
    
    func pauseGame() {
        accumulatedTime = timeElapsed
        startDate = nil
        timer?.cancel()
        timer = nil
    }
    
    func resumeGame() {
        guard !isGameFinished, timeRemaining > 0, timer == nil else { return }
        startGame()
    }
    
    func stopGame() {
        timer?.cancel()
        timer = nil
        startDate = nil
    }
    
    // MARK: - Timer Logic
    
    private func startGame() {
        startDate = Date()
        
        timer = Timer.publish(every: 0.01, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimer()
            }
    }
    
    private func updateTimer() {
        let elapsed = timeElapsed
        let remaining = totalTime - elapsed
        
        if remaining <= 0 {
            timeRemaining = 0
            finishGame()
        } else {
            timeRemaining = remaining
        }
    }
    
    // MARK: - Answer Logic
    
    func selectAnswer(_ answer: String) {
        guard let currentWord = currentWord, !isGameFinished else { return }
        
        let isCorrect = (answer == currentWord.preposition)
        
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
        
        if isCorrect {
            correctAnswers += 1
            triggerFeedback(.green)
            gameQuestions[currentIndex].registerCorrectAnswer()
        } else {
            triggerFeedback(.red)
            gameQuestions[currentIndex].registerWrongAnswer()
            AnalyticsManager.shared.logWrongAnswer(
                mode: .sprint,
                wordWithPrap: currentWord.basePreposition,
                level: selectedLevel.rawValue,
                category: categoryName,
                userAnswer: answer
            )
        }
        
        moveToNextQuestion()
    }
    
    private func moveToNextQuestion() {
        if currentIndex + 1 >= gameQuestions.count {
            finishGame()
        } else {
            currentIndex += 1
            let nextWord = gameQuestions[currentIndex]
            currentWord = nextWord
            options = PrepositionQuiz.generateOptions(correct: nextWord.preposition)
        }
    }
    
    private func finishGame() {
        let finalTime = timeElapsed
        stopGame()
        
        self.finalCapturedTime = min(finalTime, totalTime)
        isGameFinished = true        
    }
    
    func saveResult(with finalTime: TimeInterval? = nil) {
        guard !sessionCompleted else { return }
        sessionCompleted = true
        let rawTime = finalTime ?? (finalCapturedTime > 0 ? finalCapturedTime : timeElapsed)
        
        let cleanedTime = (rawTime * 100).rounded() / 100
        
        print("DEBUG: rawTime = \(rawTime), cleanedTime = \(cleanedTime)")
        
        let result = QuizResult(
            id: UUID(),
            score: correctAnswers,
            total: difficulty.questionCount,
            levelRaw: selectedLevel.rawValue,
            date: Date(),
            gameType: .sprint,
            timeElapsed: cleanedTime,
            category: categoryName
        )
        
        isNewRecord = leaderboardManager.processNewResult(result)
        
        AnalyticsManager.shared.logActivityFinished(
            mode: .sprint,
            category: categoryName,
            level: selectedLevel.rawValue,
            score: correctAnswers,
            total: difficulty.questionCount
        )
        UserProfileManager.shared.recordCompletedActivity(.sprint)
        
        if UserProfileManager.shared.isProfileSetupComplete {
            let firebaseService = FirebaseLeaderboardService()
            Task {
                await firebaseService.uploadResult(result, quizDifficulty: difficulty, profile: UserProfileManager.shared)
            }
        }
        
        saveProgressSafely()
    }
    
    func saveProgressSafely() {
        let playedQuestions = gameQuestions.prefix(currentIndex + 1)
        var hasChanges = false
        
        for playedWord in playedQuestions {
            if let index = fullWordItems.firstIndex(where: { $0.id == playedWord.id }) {
                if fullWordItems[index].learningScore != playedWord.learningScore {
                    fullWordItems[index] = playedWord
                    hasChanges = true
                }
            }
        }
        
        if !hasChanges { return }
        
        let itemsToSave = fullWordItems
        let lvl = selectedLevel.rawValue
        let cat = Category(rawValue: categoryName)?.fileName ?? "default"
        let repo = repository
        
        Task.detached(priority: .utility) {
            repo.saveItems(itemsToSave, level: lvl, category: cat)
            print("✅ Спринт: прогресс сохранен")
        }
    }
    
    private func triggerFeedback(_ color: Color) {
        feedbackColor = color.opacity(0.3)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.feedbackColor = .clear
        }
        if color == .green {
            HapticFeedback.success()
        } else if color == .red {
            HapticFeedback.error()
        }
    }
    
    func startFullSequence() {
        stopGame()
        
        isCountingDown = true
        countdownValue = 3
        isGameFinished = false
        correctAnswers = 0
        currentIndex = 0
        accumulatedTime = 0
        
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if self.countdownValue > 1 {
                    self.countdownValue -= 1
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                } else {
                    self.stopGame()
                    self.isCountingDown = false
                    
                    self.restartGame()
                }
            }
    }

    func logAbandonedIfNeeded() {
        guard !sessionCompleted else { return }
        AnalyticsManager.shared.logActivityAbandoned(
            mode: .sprint,
            category: categoryName,
            level: selectedLevel.rawValue,
            answered: resultsHistory.count,
            total: difficulty.questionCount
        )
    }
}
