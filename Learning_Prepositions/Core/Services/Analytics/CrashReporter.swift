import FirebaseCrashlytics
import Foundation

enum CrashReporter {
    static func record(_ error: Error, context: [String: String] = [:]) {
        let crashlytics = Crashlytics.crashlytics()
        for (key, value) in context {
            crashlytics.setCustomValue(value, forKey: key)
        }
        crashlytics.record(error: error)
    }

    static func record(_ error: Error, context: String) {
        record(error, context: ["context": context])
    }

    static func recordAppError(_ error: AppError, context: [String: String] = [:]) {
        guard case .noInternet = error else {
            record(error, context: context)
            return
        }
    }
}
