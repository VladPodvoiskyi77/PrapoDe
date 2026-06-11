import Foundation
import SwiftUI
import SwiftData

@Model
final class VerbEntity {
    // Делаем связку с оригинальным ID из JSON, чтобы не дублировать
    @Attribute(.unique) var base: String
    var preposition: String
    var translationRu: String
    var translationUa: String
    var translationEn: String
    var exampleSentence: String
    var caseTypeRaw: String
    var levelRaw: String
    var isShow: Bool
    var lastShownDate: Date? // Полезно для логики виджета (чтобы не повторяться)

    init(from item: VerbItem) {
        self.base = item.base
        self.preposition = item.preposition
        self.translationRu = item.translationRu
        self.translationUa = item.translationUa
        self.translationEn = item.translationEn
        self.exampleSentence = item.exampleSentence
        self.caseTypeRaw = item.caseType.rawValue
        self.levelRaw = item.level.rawValue
        self.isShow = true
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
