import Foundation

enum NewFeatureBadgePolicy {
    static let visibility: TimeInterval = 21 * 24 * 60 * 60

    static func isVisible(firstLaunch: Date?, now: Date = Date()) -> Bool {
        let start = firstLaunch ?? now
        return now.timeIntervalSince(start) < visibility
    }
}
