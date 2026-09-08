import SwiftUI

@MainActor
final class UniversalMenuViewModel: BaseDataViewModel {
    
    // MARK: - Properties
    
    private let screenType: MenuScreenType
    private let currentCategory: Category    
    @Published var menuItems: [MenuUIItem] = []
    @Published var screenTitle: String = ""
    
    @Published var showLevelHint = false
    private let hintShownKey = AppConfig.Keys.hasShownLevelHint
    private let hintDefaults = AppConfig.sharedDefaults
    
    // MARK: - Init
    
    init(type: MenuScreenType, category: Category) {
        self.screenType = type
        self.currentCategory = category
        super.init()
        
        self.setupData()
    }
    
    // MARK: - Setup Logic
    
    private func setupData() {
        self.screenTitle = screenType.title

        switch screenType {
            
        case .main:
            self.menuItems = Category.allCases.map { category in
                MenuUIItem(
                    title: category.displayTitle,
                    iconName: category.iconName,
                    iconLetter: category.iconLetter,
                    iconColor: category.iconColor,
                    payload: .category(category)
                )
            }
            if !hintDefaults.bool(forKey: hintShownKey) {
                
                Task {
                    try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
                    showLevelHint = true
                }
            }
            
        case .activity:
            self.menuItems = Activity.allCases.map { mode in
                MenuUIItem(
                    title: mode.title,
                    iconName: mode.iconName,
                    iconColor: .blue,
                    payload: .mode(mode)
                )
            }
        }
    }
    
        func markHintAsSeen() {
            withAnimation {
                showLevelHint = false
            }
            hintDefaults.set(true, forKey: hintShownKey)
        }
    
    // MARK: - Actions

    func loadWords() async -> [WordItem] {
        if let words = await performLoad(category: currentCategory) {
            return words
        }
        return []
    }
}
