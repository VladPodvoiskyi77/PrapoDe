import SwiftUI
import FirebaseCore

@main
struct Learning_prepositions_is_easyApp: App {
    init() {
        FirebaseApp.configure()
        AppConfig.migrateLegacyUserDefaultsIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(PersistenceController.sharedModelContainer)
    }
}
