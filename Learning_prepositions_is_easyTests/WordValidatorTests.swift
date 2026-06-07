import Foundation
import Testing
@testable import Learning_prepositions_is_easy

struct WordValidatorTests {
    @Test
    func validate_keepsWordWhenPrepositionExistsInExample() throws {
        let item = try TestFixtures.wordItem(
            base: "abhängig",
            preposition: "von",
            example: "Ich bin abhängig von meinen Eltern."
        )

        let validated = WordValidator().validate([item])

        #expect(validated.count == 1)
    }

    @Test
    func validate_removesWordWhenPrepositionMissingInExample() throws {
        let item = try TestFixtures.wordItem(
            base: "abhängig",
            preposition: "von",
            example: "Ich bin abhängig meinen Eltern."
        )

        let validated = WordValidator().validate([item])

        #expect(validated.isEmpty)
    }

    @Test
    func validate_isCaseInsensitiveForPrepositionMatch() throws {
        let item = try TestFixtures.wordItem(
            base: "stolz",
            preposition: "auf",
            example: "Er ist stolz Auf seine Arbeit."
        )

        let validated = WordValidator().validate([item])

        #expect(validated.count == 1)
    }
}
