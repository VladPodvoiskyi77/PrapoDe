import SwiftUI
import SwiftData
import WidgetKit

@MainActor
class WidgetWordSelectionViewModel: BaseDataViewModel {
    private let dataManager: SwiftDataManager
    
    @Published var filteredWords: [VerbEntity] = []
    @Published var allWords: [VerbEntity] = [] // Полный список уровня для фильтрации
    
    // Состояния UI (как в MyProgress)
    @Published var searchText: String = "" { didSet { applyFilters() } }
    @Published var selectedPreposition: String? = nil { didSet { applyFilters() } }
    @Published var showFilterCarousel: Bool = false
    
    // Для хедера
    var selectedCount: Int { allWords.filter { $0.isShow }.count }
    var totalCount: Int { allWords.count }
    
    // Список доступных предлогов для карусели
    var availablePrepositions: [String] {
        Array(Set(allWords.map { $0.preposition })).sorted()
    }

    init(modelContext: ModelContext) {
        self.dataManager = SwiftDataManager(context: modelContext)
        super.init()
        loadData()
    }

    func loadData() {
        // Загружаем все слова текущего уровня
        self.allWords = dataManager.fetchVerbs(level: currentLevelRaw, searchText: "")
        applyFilters()
    }

    func applyFilters() {
        var result = allWords
        
        // 1. Фильтр по поиску
        if !searchText.isEmpty {
            result = result.filter { $0.base.localizedCaseInsensitiveContains(searchText) }
        }
        
        // 2. Фильтр по карусели предлогов
        if let prep = selectedPreposition {
            result = result.filter { $0.preposition == prep }
        }
        
        self.filteredWords = result
    }

    func toggleWord(_ word: VerbEntity) {
        dataManager.updateVisibility(for: word)
        
        AnalyticsManager.shared.logWidgetCustomized(
            verb: word.base,
            isShown: word.isShow
        )
        
        objectWillChange.send()
    }
    
    func closeAndResetFilter() {
        selectedPreposition = nil
        withAnimation { showFilterCarousel = false }
    }
}
