import SwiftUI

enum RankingScope {
    case worldwide
    case country
}

final class GlobalRankingViewModel: ObservableObject {
    @Published var entries: [GlobalRankingEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var scope: RankingScope = .worldwide
    
    @Published var selectedLevel: Level
    @Published var selectedDifficulty: QuizDifficulty
    
    private let rankingProvider: LeaderboardReading
    private let profileManager: UserProfileManager
    let gameType: GameType
    
    var userCountryCode: String {
        profileManager.userCountryCode
    }
    
    var userCountryFlag: String {
        GlobalRankingEntry.flagEmoji(for: userCountryCode)
    }
    
    var canFilterByCountry: Bool {
        profileManager.isProfileSetupComplete
    }
    
    init(
        gameType: GameType,
        level: Level,
        quizDifficulty: QuizDifficulty,
        provider: LeaderboardReading = FirebaseLeaderboardService(),
        profileManager: UserProfileManager = .shared
    ) {
        self.gameType = gameType
        self.selectedLevel = level
        self.selectedDifficulty = quizDifficulty
        self.rankingProvider = provider
        self.profileManager = profileManager
    }
    
    @MainActor
    func loadRanking() async {
        isLoading = true
        errorMessage = nil
        entries = []
        
        let countryFilter: String? = scope == .country ? userCountryCode.uppercased() : nil
        
        do {
            self.entries = try await rankingProvider.fetchTopScores(
                gameType: gameType,
                quizDifficulty: selectedDifficulty,
                level: selectedLevel.rawValue,
                countryCode: countryFilter
            )
        } catch {
            self.entries = []
            self.errorMessage = L10n.WorldRanking.loadError
            print("❌ Ranking Error: \(error.localizedDescription)")
            CrashReporter.record(error, context: [
                "operation": "fetchTopScores",
                "gameType": gameType.rawValue,
                "level": selectedLevel.rawValue,
                "total": String(selectedDifficulty.questionCount),
                "scope": scope == .country ? "country" : "worldwide",
                "countryCode": countryFilter ?? "none"
            ])
        }
        isLoading = false
    }
    
    @MainActor
    func toggleScope() async {
        guard canFilterByCountry else { return }
        scope = scope == .worldwide ? .country : .worldwide
        await loadRanking()
    }
}
