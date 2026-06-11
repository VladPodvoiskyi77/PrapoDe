import Foundation
import SwiftUI

struct VerbItem: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    
    let base: String
    let preposition: String
    let translationRu: String
    let translationUa: String
    let translationEn: String
    let exampleSentence: String
    let caseType: CaseType
    let level: Level
    var isShow: Bool = true
    
    private enum CodingKeys: String, CodingKey {
        case base, preposition, translationRu, translationUa, translationEn
        case exampleSentence, caseType, level
    }
    
    init(base: String, preposition: String, translationRu: String, translationUa: String, translationEn: String, exampleSentence: String, caseType: CaseType, level: Level) {
        self.base = base
        self.preposition = preposition
        self.translationRu = translationRu
        self.translationUa = translationUa
        self.translationEn = translationEn
        self.exampleSentence = exampleSentence
        self.caseType = caseType
        self.level = level
    }
    
    // Здесь мы чиним данные, приходящие из JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.base = try container.decode(String.self, forKey: .base)
        self.preposition = try container.decode(String.self, forKey: .preposition)
        self.translationRu = try container.decode(String.self, forKey: .translationRu)
        self.translationUa = try container.decode(String.self, forKey: .translationUa)
        self.translationEn = try container.decode(String.self, forKey: .translationEn)
        self.exampleSentence = try container.decode(String.self, forKey: .exampleSentence)
        
        let levelString = try container.decode(String.self, forKey: .level)
        let cleanLevelString = levelString
            .replacingOccurrences(of: "А", with: "A")
            .replacingOccurrences(of: "В", with: "B")
            .replacingOccurrences(of: "С", with: "C")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
        
        self.level = Level(rawValue: cleanLevelString) ?? .a1
        
        let caseString = try container.decode(String.self, forKey: .caseType)
        if let type = CaseType(rawValue: caseString) {
            self.caseType = type
        } else {
            if caseString.starts(with: "Akk") { self.caseType = .akkusativ }
            else if caseString.starts(with: "Dat") { self.caseType = .dativ }
            else if caseString.starts(with: "Gen") { self.caseType = .genitiv }
            else if caseString.starts(with: "Nom") { self.caseType = .nominativ }
            else {
                print("⚠️ Неизвестный падеж в JSON: \(caseString), ставим Nominativ")
                self.caseType = .nominativ
            }
        }
    }
    
    var basePreposition: String {
        base + " " + preposition
    }
}

extension VerbItem {
    func translation(for language: Language) -> String {
        switch language {
        case .ru: return translationRu
        case .ua: return translationUa
        case .en: return translationEn
        }
    }
}
