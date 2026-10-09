enum MenuScreenType {
    case main
    case activity
    case prepositionsHub

    var title: String {
        switch self {
        case .main: return L10n.UniversalMenu.Category.title
        case .activity: return L10n.UniversalMenu.Activity.title
        case .prepositionsHub: return L10n.Prepositions.All.title
        }
    }
}

