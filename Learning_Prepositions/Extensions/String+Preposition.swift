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
}
