import SwiftUI

extension Array where Element == WordItem {
// MARK: - 1. Отдельный метод проверки (Выучено или нет)
    func isCategoryFullyLearned() -> Bool {
        guard !self.isEmpty else { return false }
        // allSatisfy вернет true, только если условие выполняется для КАЖДОГО элемента
        return self.allSatisfy { $0.isLearned }
    }
    
    // MARK: - 2. Метод генерации квиза    
    func getWordsForQuiz(count: Int) -> [WordItem] {
        // 1. ЗАЩИТА: Если слов в базе нет совсем, возвращаем пустой массив.
        guard !self.isEmpty else {
            print("⚠️ Warning: Attempted to get quiz words from an empty collection.")
            return []
        }
        
        // 2. Если слов меньше или столько же, сколько просим — просто перемешиваем и отдаем.
        if self.count <= count {
            return self.shuffled()
        }
        
        // 3. Сортируем невыученные по сложности (learningScore)
        let unlearnedSorted = self.filter { !$0.isLearned }
            .sorted { $0.learningScore < $1.learningScore }
        
        // Сценарий А: Невыученных достаточно
        if unlearnedSorted.count >= count {
            let poolSize = Swift.min(unlearnedSorted.count, count * 2)
            let challengingPool = Array(unlearnedSorted.prefix(poolSize))
            return Array(challengingPool.shuffled().prefix(count))
        }
        
        // Сценарий Б: Невыученных мало, дополняем выученными
        let unlearned = unlearnedSorted
        
        let learned = self.filter { $0.isLearned }
            .sorted {
                if $0.learningScore != $1.learningScore {
                    return $0.learningScore < $1.learningScore
                }
                return ($0.lastReviewDate ?? .distantPast) < ($1.lastReviewDate ?? .distantPast)
            }

        let needed = count - unlearned.count
        // prefix() в Swift безопасен: если элементов меньше, чем needed, он просто возьмет все.
        let fillers = Array(learned.prefix(needed))
        
        return (unlearned + fillers).shuffled()
    }
}
