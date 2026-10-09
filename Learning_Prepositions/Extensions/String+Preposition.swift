import Foundation

extension String {
    
    func hidingWord(_ word: String, placeholder: String = "___") -> String {
        let pattern = "\\b" + NSRegularExpression.escapedPattern(for: word) + "\\b"
        
        return self.replacingOccurrences(
            of: pattern,
            with: placeholder,
            options: [.regularExpression, .caseInsensitive]
        )
    }

    /// Same whole-word rule as `hidingWord`, so "zu" in "Zugang zu" is not the prefix of Zugang.
    func rangesOfStandaloneWord(_ word: String) -> [Range<String.Index>] {
        guard !word.isEmpty,
              let regex = try? NSRegularExpression(
                pattern: "\\b" + NSRegularExpression.escapedPattern(for: word) + "\\b",
                options: [.caseInsensitive]
              ) else {
            return []
        }
        let nsRange = NSRange(startIndex..<endIndex, in: self)
        return regex.matches(in: self, options: [], range: nsRange).compactMap { match in
            Range(match.range, in: self)
        }
    }
}
