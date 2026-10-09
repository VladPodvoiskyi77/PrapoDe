import Foundation
import Testing
@testable import Learning_prepositions_is_easy

struct NewFeatureBadgePolicyTests {
    @Test
    func visibleWithinThreeWeeks() {
        let start = Date(timeIntervalSince1970: 0)
        let almostThreeWeeks = start.addingTimeInterval(20 * 24 * 60 * 60)
        #expect(NewFeatureBadgePolicy.isVisible(firstLaunch: start, now: almostThreeWeeks))
    }

    @Test
    func hiddenAfterThreeWeeks() {
        let start = Date(timeIntervalSince1970: 0)
        let exactlyThreeWeeks = start.addingTimeInterval(21 * 24 * 60 * 60)
        #expect(!NewFeatureBadgePolicy.isVisible(firstLaunch: start, now: exactlyThreeWeeks))
    }

    @Test
    func visibleWhenFirstLaunchIsUnknown() {
        let now = Date(timeIntervalSince1970: 1_000)
        #expect(NewFeatureBadgePolicy.isVisible(firstLaunch: nil, now: now))
    }
}
