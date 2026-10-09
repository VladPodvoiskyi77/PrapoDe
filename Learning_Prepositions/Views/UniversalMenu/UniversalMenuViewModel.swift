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
    private let firstLaunchKey = AppConfig.Keys.firstLaunchDate
    private let hintDefaults = AppConfig.sharedDefaults
    private var didScheduleHint = false
    
    // MARK: - Init
    
    init(type: MenuScreenType, category: Category) {
        self.screenType = type
        self.currentCategory = category
        super.init()
        
        self.setupData()
    }
    
    // MARK: - Setup Logic
    
    func refreshMenu() {
        setupData()
    }
    
    private func setupData() {
        self.screenTitle = screenType.title
        let showNewBadge = NewFeatureBadgePolicy.isVisible(firstLaunch: recordedFirstLaunchDate())
        let newBadge = showNewBadge ? L10n.Category.Badge.new : nil

        switch screenType {
            
        case .main:
            var items = Category.allCases.map { category in
                MenuUIItem(
                    title: category.displayTitle,
                    iconName: category.iconName,
                    iconLetter: category.iconLetter,
                    iconColor: category.iconColor,
                    payload: .category(category),
                    badgeText: (category == .nomenverb) ? newBadge : nil
                )
            }
            let prepositionsTitle = L10n.Prepositions.All.title
            items.append(
                MenuUIItem(
                    title: "\(prepositionsTitle)\n\(L10n.Category.Prepositions.subtitle)",
                    iconName: "textformat.abc",
                    iconLetter: String(prepositionsTitle.prefix(1)).uppercased(),
                    iconColor: Color(red: 48 / 255, green: 176 / 255, blue: 199 / 255),
                    payload: .prepositionsHub,
                    badgeText: newBadge
                )
            )
            items.sort {
                menuSortKey($0).compare(menuSortKey($1), options: [.caseInsensitive], locale: .current) == .orderedAscending
            }
            self.menuItems = items
            if !didScheduleHint && !hintDefaults.bool(forKey: hintShownKey) {
                didScheduleHint = true
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

        case .prepositionsHub:
            self.menuItems = [
                MenuUIItem(
                    title: "\(L10n.Prepositions.All.title)\n\(L10n.Prepositions.All.subtitle)",
                    iconName: "list.bullet.rectangle",
                    iconColor: Color(red: 48 / 255, green: 176 / 255, blue: 199 / 255),
                    payload: .allPrepositions,
                    badgeText: newBadge
                ),
                MenuUIItem(
                    title: "\(L10n.Prepositions.GuessCase.title)\n\(L10n.Prepositions.GuessCase.subtitle)",
                    iconName: "questionmark.square.fill",
                    iconColor: .purple,
                    payload: .guessCase,
                    badgeText: newBadge
                )
            ]
        }
    }

    private func menuSortKey(_ item: MenuUIItem) -> String {
        item.title.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: false)
            .first
            .map(String.init) ?? item.title
    }
    
    func markHintAsSeen() {
        withAnimation {
            showLevelHint = false
        }
        hintDefaults.set(true, forKey: hintShownKey)
    }

    private func recordedFirstLaunchDate() -> Date {
        if let date = hintDefaults.object(forKey: firstLaunchKey) as? Date {
            return date
        }
        let now = Date()
        hintDefaults.set(now, forKey: firstLaunchKey)
        return now
    }
    
    // MARK: - Actions

    func loadWords() async -> [WordItem] {
        if let words = await performLoad(category: currentCategory) {
            return words
        }
        return []
    }
}
