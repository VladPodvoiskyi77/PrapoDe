import Foundation

// MARK: - Index (list screen)

struct PrepositionIndex: Decodable {
    let schemaVersion: Int
    let contentVersion: String?
    let groups: [PrepositionGroup]
    let items: [PrepositionIndexItem]
}

struct PrepositionGroup: Decodable, Identifiable {
    let id: String
    let sortOrder: Int
    let titles: LocalizedText
    let subtitles: LocalizedText?
}

struct PrepositionIndexItem: Decodable, Identifiable, Hashable {
    let id: String
    let lemma: String
    let caseGroup: String
    let sortOrder: Int
    let detailPath: String
    let summary: LocalizedText
}

struct LocalizedText: Decodable, Hashable {
    let ru: String
    let ua: String
    let en: String
    
    func text(for language: Language) -> String {
        switch language {
        case .ru: return ru
        case .ua: return ua
        case .en: return en
        }
    }
}

// MARK: - Detail (article screen)

struct PrepositionDetail: Decodable {
    let schemaVersion: Int
    let id: String
    let lemma: String
    let caseGroup: String
    let caseLabel: LocalizedText?
    let relatedPrepositions: [String]?
    let wechselRules: WechselRules?
    let content: PrepositionLocalizedContentMap
}

struct WechselRules: Decodable {
    let dativ: WechselRuleSide?
    let akkusativ: WechselRuleSide?
}

struct WechselRuleSide: Decodable {
    let question: String?
    let labels: LocalizedText?
}

struct PrepositionLocalizedContentMap: Decodable {
    let ru: PrepositionLocalizedContent
    let ua: PrepositionLocalizedContent
    let en: PrepositionLocalizedContent
    
    func content(for language: Language) -> PrepositionLocalizedContent {
        switch language {
        case .ru: return ru
        case .ua: return ua
        case .en: return en
        }
    }
}

struct PrepositionLocalizedContent: Decodable {
    let title: String
    let meaning: String
    let grammarNotes: [String]?
    let whenToUse: [String]?
    let commonMistakes: [String]?
    let contrastWith: [PrepositionContrast]?
    let examples: [PrepositionExample]?
}

struct PrepositionContrast: Decodable, Identifiable {
    var id: String { preposition }
    let preposition: String
    let note: String
}

struct PrepositionExample: Decodable, Identifiable {
    var id: String { de + (translation ?? "") }
    let de: String
    let translation: String?
    let usage: String?
}

struct PrepositionListSection: Identifiable {
    let group: PrepositionGroup
    let items: [PrepositionIndexItem]
    
    var id: String { group.id }
}

enum PrepositionCaseGroup: String {
    case dativ
    case akkusativ
    case wechsel
    case genitiv
    
    var accentColorName: String {
        switch self {
        case .dativ: return "purple"
        case .akkusativ: return "orange"
        case .wechsel: return "teal"
        case .genitiv: return "blue"
        }
    }
}
