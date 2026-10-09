import Foundation

struct LearningSession {
    let mode: Activity
    var answers: [AnswerResult]
}

struct AnswerResult: Identifiable, Hashable {
    let id = UUID()
    let base: String // слово (глагол/существвительное/прилагательное) с предлогом
    let preposition: String // немецкий прелог
    let prepositionTranslation: String // перевод слова (глагола/существительного/прилагательного) с предлогом
    let example: String
    let exampleTranslation: String
    let caseType: String
    let usersAnswer: String
    let correctVariants: [String]

    init(
        base: String,
        preposition: String,
        prepositionTranslation: String,
        example: String,
        exampleTranslation: String,
        caseType: String,
        usersAnswer: String,
        correctVariants: [String] = []
    ) {
        self.base = base
        self.preposition = preposition
        self.prepositionTranslation = prepositionTranslation
        self.example = example
        self.exampleTranslation = exampleTranslation
        self.caseType = caseType
        self.usersAnswer = usersAnswer
        self.correctVariants = correctVariants
    }

    var isCorrect: Bool {
        guard usersAnswer != "—" else { return false }
        return usersAnswer.isEquivalentIgnoringUmlauts(to: preposition)
            || usersAnswer.isEquivalentIgnoringUmlauts(to: base)
            || correctVariants.contains { usersAnswer.isEquivalentIgnoringUmlauts(to: $0) }
    }

    /// Quiz answers are just the preposition; writing answers are the full "verb prep".
    var reviewCorrectAnswer: String {
        reviewCorrectAnswers.first ?? preposition
    }

    var reviewCorrectAnswers: [String] {
        let uniqueVariants = Self.orderedUnique(correctVariants)
        if !uniqueVariants.isEmpty { return uniqueVariants }
        if usersAnswer == "—" || usersAnswer.contains(where: { $0.isWhitespace }) {
            return [base]
        }
        return [preposition]
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values.filter { seen.insert($0.lowercased()).inserted }
    }
}
