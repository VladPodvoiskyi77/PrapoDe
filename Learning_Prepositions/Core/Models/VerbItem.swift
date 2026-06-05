import Foundation
import SwiftUI

struct VerbItem: Identifiable, Codable, Equatable, Hashable {
    var id = UUID() // Создается автоматически, в JSON его нет
    
    let base: String
    let preposition: String
    let translationRu: String
    let translationUa: String
    let translationEn: String
    let exampleSentence: String
    let caseType: CaseType
    let level: Level
    var isShow: Bool = true
    
    // Ключи для JSON
    private enum CodingKeys: String, CodingKey {
        case base, preposition, translationRu, translationUa, translationEn
        case exampleSentence, caseType, level
    }
    
    // Стандартный init (для создания в коде)
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
    
    // 🔥 РАСШИРЕННЫЙ INIT ДЛЯ DECODABLE
    // Здесь мы чиним данные, приходящие из JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 1. Простые строки (тут всё стандартно)
        self.base = try container.decode(String.self, forKey: .base)
        self.preposition = try container.decode(String.self, forKey: .preposition)
        self.translationRu = try container.decode(String.self, forKey: .translationRu)
        self.translationUa = try container.decode(String.self, forKey: .translationUa)
        self.translationEn = try container.decode(String.self, forKey: .translationEn)
        self.exampleSentence = try container.decode(String.self, forKey: .exampleSentence)
        
        // 2. LEVEL (Лечим кириллицу и пробелы)
        let levelString = try container.decode(String.self, forKey: .level)
        let cleanLevelString = levelString
            .replacingOccurrences(of: "А", with: "A") // Русская А -> Англ A
            .replacingOccurrences(of: "В", with: "B") // Русская В -> Англ B
            .replacingOccurrences(of: "С", with: "C") // Русская С -> Англ C
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
        
        // Пытаемся создать Enum, если не вышло — ставим дефолт (например, A1)
        self.level = Level(rawValue: cleanLevelString) ?? .a1
        
        // 3. CASE TYPE (Лечим сокращения)
        let caseString = try container.decode(String.self, forKey: .caseType)
        // Пытаемся создать напрямую
        if let type = CaseType(rawValue: caseString) {
            self.caseType = type
        } else {
            // Если не вышло, пробуем "угадать" по началу слова
            if caseString.starts(with: "Akk") { self.caseType = .akkusativ }
            else if caseString.starts(with: "Dat") { self.caseType = .dativ }
            else if caseString.starts(with: "Gen") { self.caseType = .genitiv }
            else if caseString.starts(with: "Nom") { self.caseType = .nominativ }
            else {
                // Если совсем непонятно что пришло — ставим какой-то безопасный дефолт
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
