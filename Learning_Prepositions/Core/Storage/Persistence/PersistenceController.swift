import Foundation
import SwiftData

struct PersistenceController {
    static let sharedModelContainer: ModelContainer = {
        let schema = Schema([VerbEntity.self])
        let appGroupID = AppConfig.Constants.appGroupID
        // 1. ПРИНУДИТЕЛЬНО СОЗДАЕМ ДИРЕКТОРИЮ (чтобы убрать ошибки из логов)
        if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            let storageURL = groupURL.appendingPathComponent("Library/Application Support", isDirectory: true)
            if !FileManager.default.fileExists(atPath: storageURL.path) {
                try? FileManager.default.createDirectory(at: storageURL, withIntermediateDirectories: true)
            }
        }

        // 2. КОНФИГУРАЦИЯ
        let modelConfiguration = ModelConfiguration(schema: schema,
                                                    isStoredInMemoryOnly: false,
        groupContainer: .identifier(appGroupID))

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // В продакшене лучше не фаталить, но для отладки полезно
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
