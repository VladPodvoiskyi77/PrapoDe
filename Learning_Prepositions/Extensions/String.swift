import SwiftUI

extension String {
    var caseColor: Color {
        if self.contains("Akk") { return .blue.opacity(0.8) }
        if self.contains("Dat") { return .green.opacity(0.8) }
        if self.contains("Nom") { return .purple.opacity(0.8) }
        return .orange
    }
    
    func isEquivalentIgnoringUmlauts(to target: String) -> Bool {
        // Внутренняя функция для очистки строки от (sich), sich, sein и лишних пробелов
        func cleanExtraWords(_ text: String) -> String {
            let lowercased = text.lowercased()
            // Удаляем (sich), sich, sein как отдельные слова
            let stripped = lowercased.replacing(/\b\(sich\)\b|\bsich\b|\bsein\b/, with: "")
            
            // Удаляем лишние пробелы, которые могли остаться после удаления слов
            return stripped.components(separatedBy: .whitespacesAndNewlines)
                .filter { !$0.isEmpty }
                .joined(separator: " ")
        }

        // 1. Очищаем обе строки от (sich)/sein
        let inputCleaned = cleanExtraWords(self)
        let targetCleaned = cleanExtraWords(target)
        
        // 2. Применяем системный метод удаления диакритики (умлаутов)
        let inputFolded = inputCleaned.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "de_DE"))
        let targetFolded = targetCleaned.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "de_DE"))
        
        // 3. Финальное сравнение с заменой ß на ss
        return inputFolded.replacingOccurrences(of: "ß", with: "ss") ==
               targetFolded.replacingOccurrences(of: "ß", with: "ss")
    }
    
    func normalizedForGermanComparison() -> String {
        let lowercased = self.lowercased()
        // Удаляем (sich) или sich как отдельное слово
        let pattern = "\\(sich\\)|\\bsich\\b"
        let withoutSich = lowercased.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
        
        return withoutSich
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
    
    func highlightingMissingUmlauts(comparedTo input: String) -> AttributedString {
        var attributedString = AttributedString(self)
        
        // Карта соответствий умляутов латинским буквам
        let mapping: [Character: String] = [
            "ä": "a", "ö": "o", "ü": "u", "ß": "ss",
            "Ä": "A", "Ö": "O", "Ü": "U"
        ]
        
        // Нормализуем обе строки для честного сравнения (убираем sich и пробелы)
        let cleanTarget = self.normalizedForGermanComparison()
        let cleanInput = input.normalizedForGermanComparison()
        
        let targetChars = Array(cleanTarget)
        let inputChars = Array(cleanInput)
        
        // Проходим по символам правильного ответа
        for i in 0..<targetChars.count {
            let targetChar = targetChars[i]
            
            // Если текущий символ - умляут, ищем его латинский эквивалент
            if let latinEquivalent = mapping[targetChar] {
                if i < inputChars.count {
                    let userChar = String(inputChars[i])
                    
                    // ЕСЛИ юзер ввел латинскую букву вместо умляута — КРАСИМ
                    if userChar == latinEquivalent {
                        // Находим диапазон конкретно этого символа в итоговой строке
                        // Используем поиск по индексу, чтобы не покрасить лишние буквы
                        if let range = attributedString.range(of: String(targetChar)) {
                            attributedString[range].foregroundColor = .orange
                            attributedString[range].font = .system(size: 18, weight: .heavy, design: .rounded)
                        }
                    }
                }
            }
        }
        
        return attributedString
    }
    
    func highlightingGermanUmlauts(color: Color = .orange) -> AttributedString {
        var attributedString = AttributedString(self)
        let umlauts = ["ä", "ö", "ü", "ß", "Ä", "Ö", "Ü"]
        for umlaut in umlauts {
            var searchRange = attributedString.startIndex..<attributedString.endIndex
            while let range = attributedString[searchRange].range(of: umlaut) {
                attributedString[range].foregroundColor = color
                attributedString[range].font = .system(size: 18, weight: .heavy, design: .rounded)
                searchRange = range.upperBound..<attributedString.endIndex
            }
        }
        return attributedString
    }
    
    /// Parses inline Markdown (`**bold**`, `*italic*`) for preposition guide content.
    var markdownAttributedString: AttributedString {
        if let attributed = try? AttributedString(
            markdown: self,
            options: AttributedString.MarkdownParsingOptions(
                interpretedSyntax: .inlineOnlyPreservingWhitespace
            )
        ) {
            return attributed
        }
        return AttributedString(self)
    }

    var bulletMarkdownAttributedString: AttributedString {
        var bullet = AttributedString("• ")
        bullet.font = .body.bold()
        return bullet + markdownAttributedString
    }
}

