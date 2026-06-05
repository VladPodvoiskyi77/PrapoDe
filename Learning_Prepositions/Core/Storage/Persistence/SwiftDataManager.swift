import Foundation
import SwiftData
import WidgetKit

@MainActor
final class SwiftDataManager {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    /// Загрузка слов по уровню и фильтру
    func fetchVerbs(level: String, searchText: String) -> [VerbEntity] {
        let predicate = #Predicate<VerbEntity> { $0.levelRaw == level }
        let descriptor = FetchDescriptor<VerbEntity>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.base)]
        )
        
        do {
            let allWords = try context.fetch(descriptor)
            if searchText.isEmpty {
                return allWords
            } else {
                return allWords.filter { $0.base.localizedCaseInsensitiveContains(searchText) }
            }
        } catch {
            print("❌ SwiftDataManager: \(error)")
            return []
        }
    }
    
    /// Изменение статуса и уведомление виджета
    func updateVisibility(for word: VerbEntity) {
        word.isShow.toggle()
        try? context.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
}
