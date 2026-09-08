import SwiftUI
import SwiftData
import WidgetKit

@MainActor
class WidgetWordSelectionViewModel: BaseDataViewModel {
    private let dataManager: SwiftDataManager
    private let modelContext: ModelContext
    
    @Published var filteredWords: [VerbEntity] = []
    @Published var allWords: [VerbEntity] = []    
    @Published var searchText: String = "" { didSet { applyFilters() } }
    @Published var selectedPreposition: String? = nil { didSet { applyFilters() } }
    @Published var showFilterCarousel: Bool = false
    @Published var showStatusAlert = false
    @Published var statusAlertTitle = ""
    @Published var statusAlertDescription = ""
    
    private var pendingUpdateRetry = false
    
    var selectedCount: Int { allWords.filter { $0.isShow }.count }
    var totalCount: Int { allWords.count }
    
    var availablePrepositions: [String] {
        Array(Set(allWords.map { $0.preposition })).sorted()
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.dataManager = SwiftDataManager(context: modelContext)
        super.init()
        loadData()
    }

    func loadData() {
        refreshFromStore()
        Task {
            try? await repository.syncWidgetData(context: modelContext, force: false)
            refreshFromStore()
        }
    }

    private func refreshFromStore() {
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

    /// Same flow as My Progress `refreshData`: confirm → download → compare → alert.
    func refreshData() {
        pendingUpdateRetry = true
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                let result = try await repository.forceUpdateWidgetData(context: modelContext)
                switch result {
                case .updated:
                    pendingUpdateRetry = false
                    refreshFromStore()
                    statusAlertTitle = L10n.MyProgress.Update.Alert.Success.title
                    statusAlertDescription = L10n.MyProgress.Update.Alert.Success.description
                    showStatusAlert = true
                case .noChanges:
                    pendingUpdateRetry = false
                    statusAlertTitle = L10n.MyProgress.Update.Alert.NoChanges.title
                    statusAlertDescription = L10n.MyProgress.Update.Alert.NoChanges.description
                    showStatusAlert = true
                case .error:
                    statusAlertTitle = L10n.MyProgress.Update.Alert.Error.title
                    statusAlertDescription = L10n.MyProgress.Update.Alert.Error.description
                    showStatusAlert = true
                }
            } catch let error as AppError {
                appError = error
                switch error {
                case .serverError, .unknown, .decodingError:
                    showError = false
                    appError = nil
                    statusAlertTitle = L10n.MyProgress.Update.Alert.Error.title
                    statusAlertDescription = L10n.MyProgress.Update.Alert.Error.description
                    showStatusAlert = true
                case .noInternet, .contentNotAvailable:
                    showError = true
                }
            } catch {
                appError = .unknown
                showError = true
            }
        }
    }

    func retryAfterError() {
        if pendingUpdateRetry {
            refreshData()
        } else {
            loadData()
        }
    }
    
    func closeAndResetFilter() {
        selectedPreposition = nil
        withAnimation { showFilterCarousel = false }
    }
}
