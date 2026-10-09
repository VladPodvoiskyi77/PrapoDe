import Foundation

protocol LeaderboardManaging {
    /// Сохраняет результат, обновляет топ-10 и возвращает true, если это 1-е место
    func processNewResult(_ result: QuizResult) -> Bool
}

final class LeaderboardManager: LeaderboardManaging {
    private let storage: QuizResultStorage
    
    init(storage: QuizResultStorage = UserDefaultsQuizResultStorage()) {
        self.storage = storage
    }
    
    func processNewResult(_ newResult: QuizResult) -> Bool {
        var allResults = storage.load()
        allResults.append(newResult)
        
        // 2. ГРУППИРОВКА
        // Нам нужно разбить результаты на "корзины", чтобы сравнивать только сравнимое.
        let grouped = Dictionary(grouping: allResults) { result -> String in
            switch result.gameType {
            case .quiz, .writing, .guessCase:
                // Для обычного: Тип + Уровень (например: "standard_A1")
                return "\(result.gameType.rawValue)_\(result.levelRaw)"
            case .sprint:
                // Для скоростного: Тип + Уровень + Кол-во вопросов (например: "speed_A1_20")
                return "\(result.gameType.rawValue)_\(result.levelRaw)_\(result.total)"
            }
        }
        
        var finalResults: [QuizResult] = []
        var isNewRecord = false
        
        for (_, groupResults) in grouped {
            guard let firstItem = groupResults.first else { continue }
            
            let sortedGroup: [QuizResult]
            
            if firstItem.gameType == .sprint {
                sortedGroup = LeaderboardRankingLogic.sortSprintResults(groupResults)
            } else {
                sortedGroup = LeaderboardRankingLogic.sortStandardResults(groupResults)
            }
            
            let top10 = Array(sortedGroup.prefix(10))
            finalResults.append(contentsOf: top10)
            
            // Проверяем, находится ли наш новый результат на 1 месте В СВОЕЙ ГРУППЕ
            // (Важно проверять группу, к которой относится новый результат)
            let isTargetGroup = (firstItem.gameType == newResult.gameType) &&
                                (firstItem.levelRaw == newResult.levelRaw) &&
                                (firstItem.gameType == .sprint ? firstItem.total == newResult.total : true)
            
            if isTargetGroup, let best = top10.first, best.id == newResult.id {
                isNewRecord = true
            }
        }
        
        storage.save(finalResults)
        
        return isNewRecord
    }
}
