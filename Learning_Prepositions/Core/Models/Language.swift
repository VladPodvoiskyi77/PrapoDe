import Foundation

// MARK: - Поддерживаемые языки

enum Language: String, CaseIterable, Identifiable {
    case ua = "Українська"
    case en = "English"
    case ru = "Русский"
    
    var id: String { rawValue }
    
    var name: String {
        rawValue
    }
    
    var emojiFlag: String {
        switch self {
        case .ua: return "🇺🇦"
        case .en: return "🇬🇧"
        case .ru: return "🇷🇺"
        }
    }
}

extension Language {
    static var deviceLanguage: Language {
        let code = Locale.current.language.languageCode?.identifier ?? "en"
        switch code {
        case "ru": return .ru
        case "uk": return .ua
        default: return .en
        }
    }
}
