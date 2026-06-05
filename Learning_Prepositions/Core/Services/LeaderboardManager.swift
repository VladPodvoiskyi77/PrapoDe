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
        // 1. Загружаем всё, что есть
        var allResults = storage.load()
        allResults.append(newResult)
        
        // 2. ГРУППИРОВКА
        // Нам нужно разбить результаты на "корзины", чтобы сравнивать только сравнимое.
        // A1 Standard отдельно, A1 Speed (10 вопросов) отдельно, A1 Speed (30 вопросов) отдельно.
        let grouped = Dictionary(grouping: allResults) { result -> String in
            switch result.gameType {
            case .quiz, .writing:
                // Для обычного: Тип + Уровень (например: "standard_A1")
                return "\(result.gameType.rawValue)_\(result.levelRaw)"
            case .sprint:
                // Для скоростного: Тип + Уровень + Кол-во вопросов (например: "speed_A1_20")
                return "\(result.gameType.rawValue)_\(result.levelRaw)_\(result.total)"
            }
        }
        
        var finalResults: [QuizResult] = []
        var isNewRecord = false
        
        // 3. Обработка каждой группы
        for (_, groupResults) in grouped {
            guard let firstItem = groupResults.first else { continue }
            
            let sortedGroup: [QuizResult]
            
            // СОРТИРОВКА
            if firstItem.gameType == .sprint {
                sortedGroup = groupResults.sorted {
                    // 1. Сначала очки (чем больше, тем лучше)
                    if $0.score != $1.score {
                        return $0.score > $1.score
                    }
                    
                    // 2. Если очки равны, время (чем меньше, тем лучше)
                    // Примечание: я поправил знак на <, так как в Спринте быстрее = лучше
                    let time1 = $0.timeElapsed ?? Double.greatestFiniteMagnitude
                    let time2 = $1.timeElapsed ?? Double.greatestFiniteMagnitude
                    if time1 != time2 {
                        return time1 < time2
                    }
                    
                    // 3. ТВОЁ ИЗМЕНЕНИЕ: Если очки и время равны, старый результат ВЫШЕ
                    return $0.date < $1.date
                }
            } else {
                sortedGroup = groupResults.sorted {
                    // 1. Процент (чем выше, тем лучше)
                    if $0.percentage != $1.percentage {
                        return $0.percentage > $1.percentage
                    }
                    
                    // 2. ТВОЁ ИЗМЕНЕНИЕ: Если проценты равны, старый результат ВЫШЕ
                    // Вместо $0.date > $1.date ставим <
                    return $0.date < $1.date
                }
            }
            
            // ОБРЕЗКА (ТОП-10)
            let top10 = Array(sortedGroup.prefix(10))
            finalResults.append(contentsOf: top10)
            
            // ПРОВЕРКА НА РЕКОРД
            // Проверяем, находится ли наш новый результат на 1 месте В СВОЕЙ ГРУППЕ
            // (Важно проверять группу, к которой относится новый результат)
            let isTargetGroup = (firstItem.gameType == newResult.gameType) &&
                                (firstItem.levelRaw == newResult.levelRaw) &&
                                (firstItem.gameType == .sprint ? firstItem.total == newResult.total : true)
            
            if isTargetGroup, let best = top10.first, best.id == newResult.id {
                isNewRecord = true
            }
        }
        
        // 4. Сохраняем обработанный список обратно
        storage.save(finalResults)
        
        return isNewRecord
    }
}
