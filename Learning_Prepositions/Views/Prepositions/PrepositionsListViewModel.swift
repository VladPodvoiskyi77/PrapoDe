import SwiftUI

@MainActor
final class PrepositionsListViewModel: ObservableObject {
    @Published private(set) var sections: [PrepositionListSection] = []
    @Published private(set) var isLoading = false
    @Published var showError = false
    @Published var appError: AppError?
    
    @AppStorage(AppConfig.Keys.selectedLanguage, store: AppConfig.appGroupStore)
    private var selectedLanguageRawValue = Language.en.rawValue
    
    var selectedLanguage: Language {
        Language.allCases.first { $0.rawValue == selectedLanguageRawValue } ?? .en
    }
    
    private let repository: PrepositionRepository
    private var hasLoggedGuideView = false
    
    init(repository: PrepositionRepository = .shared) {
        self.repository = repository
    }
    
    func loadIndex() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let index = try await repository.fetchIndex()
            sections = Self.buildSections(from: index)
            logGuideViewIfNeeded(prepositionCount: index.items.count)
        } catch let error as AppError {
            appError = error
            showError = true
        } catch {
            appError = .serverError(error.localizedDescription)
            showError = true
        }
    }
    
    static func buildSections(from index: PrepositionIndex) -> [PrepositionListSection] {
        let sortedGroups = index.groups.sorted { $0.sortOrder < $1.sortOrder }
        return sortedGroups.compactMap { group in
            let items = index.items
                .filter { $0.caseGroup == group.id }
                .sorted { $0.sortOrder < $1.sortOrder }
            guard !items.isEmpty else { return nil }
            return PrepositionListSection(group: group, items: items)
        }
    }

    private func logGuideViewIfNeeded(prepositionCount: Int) {
        guard !hasLoggedGuideView else { return }
        hasLoggedGuideView = true
        AnalyticsManager.shared.logPrepositionsGuideViewed(
            prepositionCount: prepositionCount,
            contentLanguage: selectedLanguage.rawValue
        )
    }
}
