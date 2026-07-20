import SwiftUI
import SwiftData
import WidgetKit

@MainActor
class WidgetWordSelectionViewModel: BaseDataViewModel {
    private let dataManager: SwiftDataManager
    
    @Published var filteredWords: [VerbEntity] = []
    @Published var allWords: [VerbEntity] = []    
    @Published var searchText: String = "" { didSet { applyFilters() } }
    @Published var selectedPreposition: String? = nil { didSet { applyFilters() } }
    @Published var showFilterCarousel: Bool = false
    
    var selectedCount: Int { allWords.filter { $0.isShow }.count }
    var totalCount: Int { allWords.count }
    
    var availablePrepositions: [String] {
        Array(Set(allWords.map { $0.preposition })).sorted()
    }

    init(modelContext: ModelContext) {
        self.dataManager = SwiftDataManager(context: modelContext)
        super.init()
        loadData()
    }

    func loadData() {
        self.allWords = dataManager.fetchVerbs(level: currentLevelRaw, searchText: "")
        applyFilters()
    }

    func applyFilters() {
        var result = allWords
        
        if !searchText.isEmpty {
            result = result.filter { $0.base.localizedCaseInsensitiveContains(searchText) }
        }
        
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
        AnalyticsManager.shared.logWidgetWordsConfigured(
            enabledCount: selectedCount,
            totalCount: totalCount
        )
        
        objectWillChange.send()
    }
    
    func closeAndResetFilter() {
        selectedPreposition = nil
        withAnimation { showFilterCarousel = false }
    }
}
