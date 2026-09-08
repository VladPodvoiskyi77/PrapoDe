import SwiftUI
import FirebaseAuth
import FirebaseFirestore

final class UserProfileManager: ObservableObject {
    private static let store = AppConfig.appGroupStore

    @AppStorage("isProfileSetupComplete", store: store) var isProfileSetupComplete: Bool = false
    @AppStorage("userNickname", store: store) var userNickname: String = ""
    @AppStorage("userCountry", store: store) var userCountry: String = ""
    @AppStorage("userCountryCode", store: store) var userCountryCode: String = ""

    @Published private(set) var sessionStats = UserSessionStats()

    @Published var currentUid: String?

    static let shared = UserProfileManager()
    private let db = Firestore.firestore()
    private var authListener: AuthStateDidChangeListenerHandle?

    private init() {
        sessionStats = Self.loadSessionStats()
        startAuthListener()
    }

    // MARK: - Auth Logic

    private func startAuthListener() {
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                print("✅ UserProfileManager: Юзер найден (\(user.uid))")
                self?.currentUid = user.uid
            } else {
                print("ℹ️ UserProfileManager: Юзер не авторизован. Выполняем анонимный вход...")
                self?.signInAnonymously()
            }
        }
    }

    private func signInAnonymously() {
        Auth.auth().signInAnonymously { [weak self] authResult, error in
            if let error = error {
                print("❌ UserProfileManager: Ошибка анонимного входа: \(error.localizedDescription)")
                CrashReporter.record(error, context: "anonymousSignIn")
            } else {
                self?.currentUid = authResult?.user.uid
            }
        }
    }

    // MARK: - Profile Setup

    func setupProfile(name: String, countryName: String, countryCode: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        self.userNickname = trimmedName
        self.userCountry = countryName
        self.userCountryCode = countryCode.uppercased()
        self.isProfileSetupComplete = true

        Task {
            for _ in 0...10 {
                if currentUid != nil { break }
                try? await Task.sleep(nanoseconds: 500_000_000)
                }

            guard let uid = currentUid else {
                print("❌ UserProfileManager: Не удалось получить UID для сохранения профиля")
                return
            }

            let profile = UserProfile(
                id: uid,
                name: trimmedName,
                country: countryName,
                totalGamesPlayed: 0,
                bestSprintScore: 0,
                createdAt: Date()
            )

            do {
                try db.collection("users").document(uid).setData(from: profile)
                print("✅ UserProfileManager: Профиль \(trimmedName) успешно сохранен в Firestore")
                AnalyticsManager.shared.logProfileSetupCompleted(countryCode: countryCode)
            } catch {
                print("❌ UserProfileManager: Ошибка setData: \(error.localizedDescription)")
                CrashReporter.record(error, context: [
                    "operation": "setupProfile",
                    "userId": uid
                ])
            }
        }
    }

    func recordCompletedActivity(_ mode: Activity) {
        var stats = sessionStats
        stats.recordCompletion(for: mode)
        sessionStats = stats
        saveSessionStats(stats)
    }

    private static func loadSessionStats() -> UserSessionStats {
        guard let data = store.data(forKey: AppConfig.Keys.sessionStats),
              let stats = try? JSONDecoder().decode(UserSessionStats.self, from: data) else {
            return UserSessionStats()
        }
        return stats
    }

    private func saveSessionStats(_ stats: UserSessionStats) {
        guard let data = try? JSONEncoder().encode(stats) else { return }
        Self.store.set(data, forKey: AppConfig.Keys.sessionStats)
    }
}
