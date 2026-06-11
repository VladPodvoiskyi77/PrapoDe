import SwiftUI

@MainActor
final class PrepositionDetailViewModel: ObservableObject {
    @Published private(set) var detail: PrepositionDetail?
    @Published private(set) var isLoading = false
    @Published private(set) var isUpdating = false
    @Published var showError = false
    @Published var appError: AppError?
    @Published var showStatusAlert = false
    @Published var statusAlertTitle = ""
    @Published var statusAlertDescription = ""
    
    @AppStorage(AppConfig.Keys.selectedLanguage, store: AppConfig.appGroupStore)
    private var selectedLanguageRawValue = Language.en.rawValue
    
    var selectedLanguage: Language {
        Language.allCases.first { $0.rawValue == selectedLanguageRawValue } ?? .en
    }
    
    let prepositionId: String
    let detailPath: String
    let lemma: String
    
    private let repository: PrepositionRepository
    private var hasLoggedArticleView = false
    
    init(
        prepositionId: String,
        detailPath: String,
        lemma: String,
        repository: PrepositionRepository = .shared
    ) {
        self.prepositionId = prepositionId
        self.detailPath = detailPath
        self.lemma = lemma
        self.repository = repository
    }
    
    func loadDetail() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let loaded = try await repository.fetchDetail(
                prepositionId: prepositionId,
                detailPath: detailPath
            )
            detail = loaded
            logArticleViewIfNeeded(caseGroup: loaded.caseGroup)
        } catch let error as AppError {
            appError = error
            showError = true
        } catch {
            appError = .serverError(error.localizedDescription)
            showError = true
        }
    }
    
    var localizedContent: PrepositionLocalizedContent? {
        detail?.content.content(for: selectedLanguage)
    }
    
    func refreshDetail() async {
        guard !isUpdating else { return }
        isUpdating = true
        defer { isUpdating = false }
        
        do {
            let result = try await repository.forceUpdateDetail(path: detailPath)
            switch result {
            case .updated:
                let loaded = try await repository.fetchDetail(
                    prepositionId: prepositionId,
                    detailPath: detailPath
                )
                detail = loaded
                statusAlertTitle = L10n.Prepositions.Detail.Update.Alert.Success.title
                statusAlertDescription = L10n.Prepositions.Detail.Update.Alert.Success.description
                showStatusAlert = true
                
            case .noChanges:
                statusAlertTitle = L10n.Prepositions.Detail.Update.Alert.NoChanges.title
                statusAlertDescription = L10n.Prepositions.Detail.Update.Alert.NoChanges.description
                showStatusAlert = true
                
            case .error(let message):
                appError = .serverError(message)
                showError = true
            }
        } catch let error as AppError {
            appError = error
            showError = true
        } catch {
            appError = .serverError(error.localizedDescription)
            showError = true
        }
    }
    
    func examples(for usage: String?) -> [PrepositionExample] {
        guard let examples = localizedContent?.examples else { return [] }
        guard let usage else { return examples }
        return examples.filter { ($0.usage ?? "").lowercased() == usage.lowercased() }
    }

    private func logArticleViewIfNeeded(caseGroup: String) {
        guard !hasLoggedArticleView else { return }
        hasLoggedArticleView = true
        AnalyticsManager.shared.logPrepositionArticleViewed(
            prepositionId: prepositionId,
            lemma: lemma,
            caseGroup: caseGroup,
            contentLanguage: selectedLanguage.rawValue
        )
    }
}
