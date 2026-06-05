import SwiftUI

@MainActor
final class SplashViewModel: ObservableObject {    
    // Состояние анимации UI
    @Published var contentScale = 0.8
    @Published var contentOpacity = 0.0
    
    private let userDefaults: UserDefaults
    
    // Dependency Injection для тестируемости
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func onAppear() {
        // 1. Настройка языка (Smart Setup)
        setupInitialData()
        
        // 2. Запуск анимации появления
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            contentScale = 1.0
            contentOpacity = 1.0
        }
    }
    
    private func setupInitialData() {
        // Используем именно App Group!
        let groupDefaults = AppConfig.appGroupStore
        let langKey = AppConfig.Keys.selectedLanguage
        let levelKey = AppConfig.Keys.selectedLevel
        
        if groupDefaults.object(forKey: langKey) == nil {
            let detectedLang = Language.deviceLanguage
            groupDefaults.set(detectedLang.rawValue, forKey: langKey)
            print("🌍 First Launch: Saved to AppGroup -> \(detectedLang.name)")
        }
        
        if groupDefaults.object(forKey: levelKey) == nil {
            let defaultLevel = Level.a1.rawValue
            groupDefaults.set(defaultLevel, forKey: levelKey)
            AnalyticsManager.shared.setUserLevel(defaultLevel)
            print("📈 First Launch: Saved Default Level to AppGroup -> \(defaultLevel)")
        } else if let existingLevel = groupDefaults.string(forKey: levelKey) {
            AnalyticsManager.shared.setUserLevel(existingLevel)
        }
        
        groupDefaults.synchronize()
    }
}

