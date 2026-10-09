import SwiftUI

enum Category: String, CaseIterable, Hashable {
    case verben = "Verben mit Präpositionen"
    case adjektive = "Adjektive mit Präpositionen"
    case nomen = "Nomen mit Präpositionen"
    case nomenverb = "Nomen-Verb-Verbindungen"

    /// Stable German label for analytics, Firestore, and global ranking.
    var analyticsName: String { rawValue }

    /// Localized title for UI (follows app language from Settings).
    var displayTitle: String {
        switch self {
        case .verben:
            return "\(L10n.Category.Verben.title)\n\(L10n.Category.Verben.subtitle)"
        case .adjektive:
            return "\(L10n.Category.Adjektive.title)\n\(L10n.Category.Adjektive.subtitle)"
        case .nomen:
            return "\(L10n.Category.Nomen.title)\n\(L10n.Category.Nomen.subtitle)"
        case .nomenverb:
            return "\(L10n.Category.Nomenverb.title)\n\(L10n.Category.Nomenverb.subtitle)"
        }
    }

    var fileName: String {
        switch self {
        case .adjektive: return "adjektive"
        case .nomen: return "nomen"
        case .verben: return "verben"
        case .nomenverb: return "nomenverb"
        }
    }

    var iconName: String {
        switch self {
        case .adjektive: return "a.square.fill"
        case .nomen: return "n.square.fill"
        case .verben: return "v.square.fill"
        case .nomenverb: return "link.circle.fill"
        }
    }

    /// First letter of the localized category title (Глаголы → Г, Дієслова → Д).
    var iconLetter: String {
        String(localizedTitle.prefix(1)).uppercased()
    }

    var localizedTitle: String {
        switch self {
        case .verben: return L10n.Category.Verben.title
        case .adjektive: return L10n.Category.Adjektive.title
        case .nomen: return L10n.Category.Nomen.title
        case .nomenverb: return L10n.Category.Nomenverb.title
        }
    }

    var iconColor: Color {
        switch self {
        case .adjektive: return .purple
        case .nomen: return .orange
        case .verben: return .blue
        case .nomenverb: return Color(red: 52 / 255, green: 199 / 255, blue: 89 / 255)
        }
    }
}
