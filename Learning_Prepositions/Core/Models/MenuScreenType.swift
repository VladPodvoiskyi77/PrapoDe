enum MenuScreenType {
    case main
    case activity
    
    // Заголовок экрана
    var title: String {
        switch self {
        case .main: return L10n.UniversalMenu.Category.title
        case .activity: return L10n.UniversalMenu.Activity.title
        }
    }
}

