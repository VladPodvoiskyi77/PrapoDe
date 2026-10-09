import SwiftUI

// MARK: - Основная модель данных
struct WordItem: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    
    let base: String
    let preposition: String
    // правильный предлог ("von")
    let translationRu: String
    let translationUa: String
    let translationEn: String
    let caseType: String
    let example: String
    let exampleRu: String
    let exampleUa: String
    let exampleEn: String
    var learningScore: Int
    var isLearned: Bool
    var lastReviewDate: Date?
    
    static let masteryThreshold = 5
    
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case id, base, preposition, translationRu, translationUa, translationEn
        case caseType, example, exampleRu, exampleUa, exampleEn
        case learningScore, isLearned, lastReviewDate
    }
    
    // MARK: - Init from Decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.base = try container.decode(String.self, forKey: .base)
        self.preposition = try container.decode(String.self, forKey: .preposition)
        self.translationRu = try container.decode(String.self, forKey: .translationRu)
        self.translationUa = try container.decode(String.self, forKey: .translationUa)
        self.translationEn = try container.decode(String.self, forKey: .translationEn)
        self.caseType = try container.decode(String.self, forKey: .caseType)
        self.example = try container.decode(String.self, forKey: .example)
        self.exampleRu = try container.decode(String.self, forKey: .exampleRu)
        self.exampleUa = try container.decode(String.self, forKey: .exampleUa)
        self.exampleEn = try container.decode(String.self, forKey: .exampleEn)
        
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        learningScore = try container.decodeIfPresent(Int.self, forKey: .learningScore) ?? 0
        isLearned = try container.decodeIfPresent(Bool.self, forKey: .isLearned) ?? false
        lastReviewDate = try container.decodeIfPresent(Date.self, forKey: .lastReviewDate)
    }
    
    var basePreposition: String {
        [base, preposition].filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.joined(separator: " ")
    }
    
    func getAnswerOptions() -> [String] {
        PrepositionQuiz.generateOptions(correct: preposition)
    }
    
    func translation(for language: Language) -> String {
        switch language {
        case .ru: return exampleRu
        case .ua: return exampleUa
        case .en: return exampleEn
        }
    }
    
    func translationWordWithPrep(for language: Language) -> String {
        switch language {
        case .ru: return translationRu
        case .ua: return translationUa
        case .en: return translationEn
        }
    }
    
    func exampleWithHiddenPreposition() -> String {
        example.hidingWord(preposition)
    }
    
    func exampleWithHighlighted(word: String, color: Color = .orange, size: CGFloat = 26) -> AttributedString {
        var attributedString = AttributedString(example)
        for range in example.rangesOfStandaloneWord(word).reversed() {
            guard let attributedRange = Range(range, in: attributedString) else { continue }
            attributedString[attributedRange].foregroundColor = color
            attributedString[attributedRange].font = .system(size: size, weight: .black, design: .rounded)
        }
        return attributedString
    }
    
    mutating func registerCorrectAnswer() {
        learningScore += 1
        lastReviewDate = Date()
        if learningScore >= Self.masteryThreshold {
            isLearned = true
        }
    }
    
    mutating func registerWrongAnswer() {
        if isLearned {
            isLearned = false
            learningScore = max(0, Self.masteryThreshold - 2)
        } else {
            learningScore = max(0, learningScore - 1)
        }
        lastReviewDate = Date()
    }
}

extension WordItem {
    
    func formattedTranslation(for language: Language) -> String {
        return "\(basePreposition) - \(translationWordWithPrep(for: language))"
    }
    var caseColor: Color {
        caseType.caseColor
    }

    var quizCase: CaseType? {
        CaseType.quizCase(from: caseType)
    }
}

extension Array where Element == WordItem {
    func sortedAlphabetically(language: Language, descending: Bool = false) -> [WordItem] {
        sorted { lhs, rhs in
            let result = language.compare(lhs.base, rhs.base)
            if descending {
                return result == .orderedDescending
            }
            return result == .orderedAscending
        }
    }
}

struct PrepositionQuiz {
    static let all = ["von", "über", "auf", "mit", "um", "nach", "zu", "an", "bei", "gegen", "aus", "unter"]
    
    static func generateOptions(correct: String) -> [String] {
        let wrong = all.filter { $0 != correct }.shuffled().prefix(3)
        return (wrong + [correct]).shuffled()
    }
}
