import Foundation
import Testing
@testable import Learning_prepositions_is_easy

struct PrepositionHighlightTests {
    @Test
    func hidingWord_stillBlanksOrdinaryPrepositions() {
        #expect("Ich bin abhängig von meinen Eltern.".hidingWord("von") == "Ich bin abhängig ___ meinen Eltern.")
        #expect("Er ist stolz Auf seine Arbeit.".hidingWord("auf") == "Er ist stolz ___ seine Arbeit.")
    }

    @Test
    func hidingWord_keepsZugangAndBlanksStandaloneZu() {
        let example = "Nicht jeder hat Zugang zu schnellem Internet."
        #expect(example.hidingWord("zu") == "Nicht jeder hat Zugang ___ schnellem Internet.")
    }

    @Test
    func rangesOfStandaloneWord_skipsPrefixInsideZugang() {
        let example = "Nicht jeder hat Zugang zu schnellem Internet."
        let ranges = example.rangesOfStandaloneWord("zu")
        #expect(ranges.count == 1)
        #expect(String(example[ranges[0]]) == "zu")

        let zugang = example.range(of: "Zugang")
        #expect(zugang != nil)
        #expect(ranges[0].lowerBound > zugang!.upperBound)
    }
}
