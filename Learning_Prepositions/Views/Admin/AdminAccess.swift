import Foundation
import UIKit

enum AdminAccess {
    static let requiredTaps = 10
    static let tapResetInterval: TimeInterval = 3.0

    static var deviceId: String {
        let key = "adminDeviceId"
        if let existing = UserDefaults.standard.string(forKey: key), !existing.isEmpty {
            return existing
        }
        let id = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        UserDefaults.standard.set(id, forKey: key)
        return id
    }
}
