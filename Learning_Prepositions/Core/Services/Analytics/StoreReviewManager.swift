import StoreKit
import UIKit

enum StoreReviewManager {
    private static let minimumAccuracy = 0.8
    private static let minimumDaysBetweenRequests = 90

    static func requestReviewIfEligible(score: Int, total: Int, gameType: GameType) {
        guard total > 0 else { return }
        guard gameType == .quiz || gameType == .sprint || gameType == .guessCase else { return }

        let accuracy = Double(score) / Double(total)
        guard accuracy >= minimumAccuracy else { return }

        let defaults = AppConfig.sharedDefaults
        if let lastRequest = defaults.object(forKey: AppConfig.Keys.lastReviewRequestDate) as? Date {
            let days = Calendar.current.dateComponents([.day], from: lastRequest, to: Date()).day ?? 0
            guard days >= minimumDaysBetweenRequests else { return }
        }

        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            return
        }

        SKStoreReviewController.requestReview(in: scene)
        defaults.set(Date(), forKey: AppConfig.Keys.lastReviewRequestDate)
    }
}
