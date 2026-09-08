import Foundation
import SwiftUI
import SwiftData

@Model
final class VerbEntity {
    /// base|preposition|level — not @unique: Firebase JSON has rare duplicate rows,
    /// and a leftover unique-on-base index from older schema collapsed A1 → ~11–16.
    var catalogId: String
    var base: String
    var preposition: String
    var translationRu: String
    var translationUa: String
    var translationEn: String
    var exampleSentence: String
    var caseTypeRaw: String
    var levelRaw: String
    var isShow: Bool
    var lastShownDate: Date?

    init(from item: VerbItem) {
        let level = item.level.rawValue
        self.catalogId = Self.makeCatalogId(base: item.base, preposition: item.preposition, levelRaw: level)
        self.base = item.base.trimmingCharacters(in: .whitespacesAndNewlines)
        self.preposition = item.preposition.trimmingCharacters(in: .whitespacesAndNewlines)
        self.translationRu = item.translationRu
        self.translationUa = item.translationUa
        self.translationEn = item.translationEn
        self.exampleSentence = item.exampleSentence
        self.caseTypeRaw = item.caseType.rawValue
        self.levelRaw = level
        self.isShow = true
    }

    static func makeCatalogId(base: String, preposition: String, levelRaw: String) -> String {
        let b = base.trimmingCharacters(in: .whitespacesAndNewlines)
        let p = preposition.trimmingCharacters(in: .whitespacesAndNewlines)
        let l = levelRaw.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        return "\(b)|\(p)|\(l)"
    }
    
    var basePreposition: String {
        base + " " + preposition
    }
    
    var caseColor: Color {
        let type = caseTypeRaw.lowercased()
        if type.contains("nom") { return .green }
        if type.contains("akk") { return .blue }
        if type.contains("dat") { return .teal }
        if type.contains("gen") { return .red }
        return .gray
    }
    
    var shortCaseName: String {
        let type = caseTypeRaw.lowercased()
        if type.contains("nom") { return "NOM" }
        if type.contains("akk") { return "AKK" }
        if type.contains("dat") { return "DAT" }
        if type.contains("gen") { return "GEN" }
        return "???"
    }
    
    func getTranslation(for language: Language) -> String {
        switch language {
        case .ru: return translationRu
        case .ua: return translationUa
        case .en: return translationEn
        }
    }
}
