import SwiftUI

protocol SettingsStorage {
    func resetResults()
}

@MainActor
final class SettingsViewModel: ObservableObject {
    
    private let storage: SettingsStorage
    
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "v \(version) (\(build))"
    }
    
    init(storage: SettingsStorage = UserDefaultsQuizResultStorage()) {
        self.storage = storage
    }
    
    func resetResults() {
        storage.resetResults()
    }
    
    // MARK: - Email Logic
    func getSupportEmailURL() -> URL? {
        let email = AppConfig.Support.email
        let subject = "Feedback: " + AppConfig.Support.appName
        let body = L10n.Settings.Section.Feedback.Email.text
        
        return createEmailUrl(to: email, subject: subject, body: body)
    }
    
    private func createEmailUrl(to: String, subject: String, body: String) -> URL? {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let strategies = [
            "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)",
            "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)",
            "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)"
        ]
        
        for str in strategies {
            if let url = URL(string: str), UIApplication.shared.canOpenURL(url) {
                return url
            }
        }
        return nil
    }
}

extension UserDefaultsQuizResultStorage: SettingsStorage {
    func resetResults() {
        deleteAllResults()
    }
}
