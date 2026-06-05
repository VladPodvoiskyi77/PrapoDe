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

    // Закрытый init для синглтона
    private init() {
        startAuthListener()
    }

    // MARK: - Auth Logic
    
    private func startAuthListener() {
        // Этот метод вызывается один раз при старте.
        // Он автоматически подхватит юзера, если тот уже заходил ранее.
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
        // ШАГ 1: Локальное сохранение (мгновенно)
        self.userNickname = name
        self.userCountry = countryName
        self.userCountryCode = countryCode.uppercased()
        self.isProfileSetupComplete = true
        
        Task {
            for _ in 0...10 {
                if currentUid != nil { break }
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 сек
            }
            
            guard let uid = currentUid else {
                print("❌ UserProfileManager: Не удалось получить UID для сохранения профиля")
                return
            }
            
            let profile = UserProfile(
                id: uid,
                name: name,
                country: countryName,
                totalGamesPlayed: 0,
                bestSprintScore: 0,
                createdAt: Date()
            )
            
            do {
                try db.collection("users").document(uid).setData(from: profile)
                print("✅ UserProfileManager: Профиль \(name) успешно сохранен в Firestore")
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
}
