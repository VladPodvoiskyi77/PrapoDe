import SwiftUI

final class LeaderboardViewModel: ObservableObject {
    @Published var results: [QuizResult] = []
    private let storage: QuizResultStorage
    
    @AppStorage("selectedLevel", store: UserDefaults(suiteName: AppConfig.Constants.appGroupID))
    private var globalUserLevelRaw = Level.a1.rawValue

    @Published var selectedFilter: Level = .a1
    @Published var selectedGameType: GameType
    @Published var selectedDifficulty: QuizDifficulty
    
    init(storage: QuizResultStorage = UserDefaultsQuizResultStorage(), resultContext: ResultContext) {
        self.selectedGameType = resultContext.gameType
        self.selectedDifficulty = resultContext.quizDifficulty
        self.storage = storage
        load()
    }
    
    func load() {
        if let savedLevel = Level(rawValue: globalUserLevelRaw) {
            selectedFilter = savedLevel
        }
        results = storage.load()
    }

    func sortedData() -> [QuizResult] {
        return results
            .filter { result in
                let levelMatch = result.levelRaw == selectedFilter.rawValue
                
                let typeMatch = result.gameType == selectedGameType
                
                var difficultyMatch = true
                if selectedGameType == .sprint {
                    difficultyMatch = result.total == selectedDifficulty.questionCount
                }
                
                return levelMatch && typeMatch && difficultyMatch
            }
            .sorted { (res1, res2) -> Bool in
                if selectedGameType == .sprint {
                    if res1.score != res2.score {
                        return res1.score > res2.score
                    }
                    return (res1.timeElapsed ?? 999) < (res2.timeElapsed ?? 999)
                } else {
                    if res1.percentage != res2.percentage {
                        return res1.percentage > res2.percentage
                    }
                    return res1.date < res2.date
                }
            }
    }
}

