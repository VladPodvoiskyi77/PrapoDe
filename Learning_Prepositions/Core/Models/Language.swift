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

    /// Bundle language code for Localizable.strings (in-app translation language).
    var localizationCode: String {
        switch self {
        case .ua: return "uk"
        case .en: return "en"
        case .ru: return "ru"
        }
    }

    /// Resolves a Localizable key using the in-app language, not the system locale.
    func localized(_ key: String, fallback: String, table: String = "Localizable") -> String {
        guard let path = Bundle.main.path(forResource: localizationCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return fallback
        }
        return bundle.localizedString(forKey: key, value: fallback, table: table)
    }
}
