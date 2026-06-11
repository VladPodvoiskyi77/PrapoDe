import SwiftUI

extension Array where Element == WordItem {
// MARK: - 1. Отдельный метод проверки (Выучено или нет)
    func isCategoryFullyLearned() -> Bool {
        guard !self.isEmpty else { return false }
        return self.allSatisfy { $0.isLearned }
    }
    
    // MARK: - 2. Метод генерации квиза    
    func getWordsForQuiz(count: Int) -> [WordItem] {
        guard !self.isEmpty else {
            print("⚠️ Warning: Attempted to get quiz words from an empty collection.")
            return []
        }
        
        if self.count <= count {
            return self.shuffled()
        }
        
        let unlearnedSorted = self.filter { !$0.isLearned }
            .sorted { $0.learningScore < $1.learningScore }
        
        if unlearnedSorted.count >= count {
            let poolSize = Swift.min(unlearnedSorted.count, count * 2)
            let challengingPool = Array(unlearnedSorted.prefix(poolSize))
            return Array(challengingPool.shuffled().prefix(count))
        }
        
        let unlearned = unlearnedSorted
        
        let learned = self.filter { $0.isLearned }
            .sorted {
                if $0.learningScore != $1.learningScore {
                    return $0.learningScore < $1.learningScore
                }
                return ($0.lastReviewDate ?? .distantPast) < ($1.lastReviewDate ?? .distantPast)
            }

        let needed = count - unlearned.count
        let fillers = Array(learned.prefix(needed))
        
        return (unlearned + fillers).shuffled()
    }
}
