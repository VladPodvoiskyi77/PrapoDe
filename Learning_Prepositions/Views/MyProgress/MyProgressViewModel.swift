import SwiftUI

@MainActor
class MyProgressViewModel: BaseDataViewModel {
    
    // MARK: - Данные
    @Published var words: [WordItem] = []
    @Published var searchText = ""
    @Published var showStatusAlert = false
    @Published var statusAlertTitle = ""
    @Published var statusAlertDescription = ""
    
    // MARK: - Настройки
    
    @Published var showFilterCarousel = false
    @Published var selectedPreposition: String? = nil
    @Published var activePreposition: String? = nil
    private let category: Category
    private var pendingUpdateRetry = false
    
    // MARK: - Init
    init(category: Category) {
        self.category = category
        super.init()
        
        Task {
            await loadData()
        }
    }
    
    // MARK: - Логика фильтрации
    
    var availablePrepositions: [String] {
        let allPreps = words.map { $0.preposition }
        return Array(Set(allPreps)).sorted()
    }
    
    var filteredWords: [WordItem] {
        let searchResult: [WordItem]
        
        if searchText.isEmpty {
            searchResult = words
        } else {
            searchResult = words.filter {
                $0.basePreposition.localizedCaseInsensitiveContains(searchText) ||
                $0.translation(for: currentLanguage)
                    .localizedCaseInsensitiveContains(searchText)
            }
        }
        
        let filtered: [WordItem]
        if let prep = activePreposition {
            filtered = searchResult.filter { $0.preposition == prep }
        } else {
            filtered = searchResult
        }
        return filtered.sortedAlphabetically(language: currentLanguage)
    }
    
    func closeAndResetFilter() {
        withAnimation(.spring()) {
            showFilterCarousel = false
            selectedPreposition = nil
            activePreposition = nil
        }
    }
    
    // MARK: - Загрузка данных
    func loadData() async {
        guard let loaded = await performLoad(category: category) else {
            return
        }
        
        self.words = loaded
    }
    
    func refreshData() {
        pendingUpdateRetry = true
        Task {
            let (newItems, result) = await performUpdate(category: category)
            
            switch result {
            case .updated:
                pendingUpdateRetry = false
                if let items = newItems {
                    self.words = items
                    self.statusAlertTitle = L10n.MyProgress.Update.Alert.Success.title
                    self.statusAlertDescription = L10n.MyProgress.Update.Alert.Success.description
                    self.showStatusAlert = true
                }
                
            case .noChanges:
                pendingUpdateRetry = false
                self.statusAlertTitle = L10n.MyProgress.Update.Alert.NoChanges.title
                self.statusAlertDescription = L10n.MyProgress.Update.Alert.NoChanges.description
                self.showStatusAlert = true
                
            case .error:
                switch appError {
                case .serverError, .unknown:
                    showError = false
                    appError = nil
                    self.statusAlertTitle = L10n.MyProgress.Update.Alert.Error.title
                    self.statusAlertDescription = L10n.MyProgress.Update.Alert.Error.description
                    self.showStatusAlert = true
                default:
                    break
                }
            }
        }
    }
    
    func retryAfterError() async {
        if pendingUpdateRetry {
            refreshData()
        } else {
            await loadData()
        }
    }
    
    // MARK: - Статистика
    
    var totalWords: Int {
        words.count
    }
    
    var learnedWords: Int {
        words.filter { $0.isLearned }.count
    }
    
    var progressValue: Double {
        guard totalWords > 0 else { return 0 }
        return Double(learnedWords) / Double(totalWords)
    }
}
