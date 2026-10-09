import SwiftUI

@MainActor
final class GuessCaseViewModel: BaseDataViewModel {
    static let analyticsCategory = "Guess the case"

    private let validator: WordValidating = WordValidator()
    private let leaderboardManager: LeaderboardManaging

    @Published private(set) var wordItems: [WordItem] = []
    @Published var resultsHistory: [AnswerResult] = []
    @Published var currentIndex = 0
    @Published var selectedAnswer: String?
    @Published var isAnswered = false
    @Published var isReady = false

    private var candidateWords: [WordItem] = []
    private var sessionCompleted = false
    var correctAnswers = 0
    var totalQuestions = 0
    private var safeCount = 0

    var isSessionCompleted: Bool { sessionCompleted }

    var selectedLevel: Level { Level(rawValue: currentLevelRaw) ?? .a1 }

    let caseOptions = CaseType.quizCases

    var currentWord: WordItem? {
        wordItems[safe: currentIndex]
    }

    var currentQuizCase: CaseType? {
        currentWord?.quizCase
    }

    init(manager: LeaderboardManaging? = nil) {
        self.leaderboardManager = manager ?? LeaderboardManager(storage: UserDefaultsQuizResultStorage())
        super.init()
    }

    func startOrRestart() async {
        if isSessionCompleted || wordItems.isEmpty {
            await loadPool()
        }
        guard !candidateWords.isEmpty else { return }
        refreshData()
        isReady = true
    }

    func loadPool() async {
        isLoading = true
        defer { isLoading = false }

        var collected: [WordItem] = []
        var lastError: AppError?

        for category in Category.allCases {
            do {
                let items: [WordItem] = try await repository.fetchItems(
                    level: currentLevelRaw,
                    category: category.fileName
                )
                collected.append(contentsOf: validator.validate(items))
            } catch let error as AppError {
                lastError = error
            } catch {
                lastError = .unknown
            }
        }

        let eligible = collected.filter { $0.quizCase != nil }
        if eligible.isEmpty {
            appError = lastError ?? .contentNotAvailable
            showError = true
            candidateWords = []
            wordItems = []
            isReady = true
            return
        }

        candidateWords = eligible
        let limit = AppConfig.sharedDefaults.integer(forKey: AppConfig.Keys.questionCount)
        let questionLimit = limit > 0 ? limit : 10
        safeCount = min(questionLimit, eligible.count)
    }

    func refreshData() {
        AnalyticsManager.shared.logActivityStarted(
            mode: .quiz,
            category: Self.analyticsCategory,
            level: selectedLevel.rawValue
        )

        let items = candidateWords.getWordsForQuiz(count: safeCount)
        wordItems = items
        totalQuestions = items.count
        currentIndex = 0
        correctAnswers = 0
        isAnswered = false
        selectedAnswer = nil
        resultsHistory.removeAll()
        sessionCompleted = false
    }

    func selectAnswer(_ answer: String) {
        guard !isAnswered, let word = currentWord, let quizCase = word.quizCase else { return }
        selectedAnswer = answer
        isAnswered = true

        let isCorrect = answer == quizCase.rawValue
        if isCorrect {
            correctAnswers += 1
        } else {
            AnalyticsManager.shared.logWrongAnswer(
                mode: .quiz,
                wordWithPrap: word.basePreposition,
                level: selectedLevel.rawValue,
                category: Self.analyticsCategory,
                userAnswer: answer
            )
        }

        resultsHistory.append(
            AnswerResult(
                base: word.basePreposition,
                preposition: word.preposition,
                prepositionTranslation: word.translationWordWithPrep(for: currentLanguage),
                example: word.example,
                exampleTranslation: word.translation(for: currentLanguage),
                caseType: quizCase.rawValue,
                usersAnswer: answer,
                correctVariants: [quizCase.rawValue]
            )
        )
    }

    func nextQuestion() {
        guard currentIndex + 1 < wordItems.count else { return }
        currentIndex += 1
        isAnswered = false
        selectedAnswer = nil
    }

    func buttonColor(for option: String) -> Color {
        guard isAnswered, let quizCase = currentQuizCase else { return .white }
        if option == quizCase.rawValue { return .green.opacity(0.8) }
        if option == selectedAnswer { return .red.opacity(0.8) }
        return .white
    }

    func saveResult() {
        sessionCompleted = true
        let result = QuizResult(
            id: UUID(),
            score: correctAnswers,
            total: totalQuestions,
            levelRaw: selectedLevel.rawValue,
            date: Date(),
            gameType: .guessCase,
            timeElapsed: nil,
            category: Self.analyticsCategory
        )

        AnalyticsManager.shared.logActivityFinished(
            mode: .quiz,
            category: Self.analyticsCategory,
            level: selectedLevel.rawValue,
            score: correctAnswers,
            total: result.total
        )

        _ = leaderboardManager.processNewResult(result)
        UserProfileManager.shared.recordCompletedActivity(.quiz)
    }

    func logAbandonedIfNeeded() {
        guard !sessionCompleted else { return }
        AnalyticsManager.shared.logActivityAbandoned(
            mode: .quiz,
            category: Self.analyticsCategory,
            level: selectedLevel.rawValue,
            answered: resultsHistory.count,
            total: totalQuestions
        )
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
