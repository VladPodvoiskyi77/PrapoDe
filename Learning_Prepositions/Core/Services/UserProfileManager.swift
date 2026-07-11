import SwiftUI
import FirebaseAuth
import FirebaseFirestore

final class UserProfileManager: ObservableObject {
    private static let store = AppConfig.appGroupStore

    @AppStorage("isProfileSetupComplete", store: store) var isProfileSetupComplete: Bool = false
    @AppStorage("userNickname", store: store) var userNickname: String = ""
    @AppStorage("userCountry", store: store) var userCountry: String = ""
    @AppStorage("userCountryCode", store: store) var userCountryCode: String = ""
    
    @Published var currentUid: String?
    
    static let shared = UserProfileManager()
    private let db = Firestore.firestore()
    private var authListener: AuthStateDidChangeListenerHandle?

    private init() {
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
                completedQuizzes: 0,
                completedTrainings: 0,
                completedSprints: 0,
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
        guard let uid = currentUid else { return }

        let field: String
        switch mode {
        case .quiz: field = "completedQuizzes"
        case .training: field = "completedTrainings"
        case .sprint: field = "completedSprints"
        case .writing, .myProgress: return
        }

        Task {
            do {
                try await db.collection("users").document(uid).updateData([
                    field: FieldValue.increment(Int64(1)),
                    "totalGamesPlayed": FieldValue.increment(Int64(1))
                ])
            } catch {
                // Profile document may not exist yet for users who skipped onboarding.
            }
        }
    }
}
