import Foundation
import Testing
@testable import Learning_prepositions_is_easy

struct GuessCaseQuizTests {
    @Test
    func quizCase_readsAkkDatGen() {
        #expect(CaseType.quizCase(from: "Akkusativ") == .akkusativ)
        #expect(CaseType.quizCase(from: "auf + Akk") == .akkusativ)
        #expect(CaseType.quizCase(from: "Dativ") == .dativ)
        #expect(CaseType.quizCase(from: "mit + Dat") == .dativ)
        #expect(CaseType.quizCase(from: "Genitiv") == .genitiv)
    }

    @Test
    func quizCase_skipsNominativAndFest() {
        #expect(CaseType.quizCase(from: "Nominativ") == nil)
        #expect(CaseType.quizCase(from: "fest") == nil)
        #expect(CaseType.quizCase(from: "") == nil)
    }

    @Test
    func answerResult_treatsCaseChoiceAsCorrect() {
        let result = AnswerResult(
            base: "warten auf",
            preposition: "auf",
            prepositionTranslation: "to wait for",
            example: "Ich warte auf den Bus.",
            exampleTranslation: "I am waiting for the bus.",
            caseType: "Akkusativ",
            usersAnswer: "Akkusativ",
            correctVariants: ["Akkusativ"]
        )
        #expect(result.isCorrect)
        #expect(result.reviewCorrectAnswers == ["Akkusativ"])
    }

    @Test
    func answerResult_marksWrongCase() {
        let result = AnswerResult(
            base: "warten auf",
            preposition: "auf",
            prepositionTranslation: "to wait for",
            example: "Ich warte auf den Bus.",
            exampleTranslation: "I am waiting for the bus.",
            caseType: "Akkusativ",
            usersAnswer: "Dativ",
            correctVariants: ["Akkusativ"]
        )
        #expect(!result.isCorrect)
        #expect(result.reviewCorrectAnswer == "Akkusativ")
    }
}
