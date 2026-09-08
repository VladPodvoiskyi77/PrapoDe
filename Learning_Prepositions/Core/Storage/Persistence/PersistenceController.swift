import Foundation
import SwiftData

enum WidgetCatalog {
    static let versionKey = "widgetCatalogVersion"
    /// Bump when widget SwiftData schema / sync rules change. Forces store wipe + re-download.
    static let currentVersion = 3
}

struct PersistenceController {
    static let sharedModelContainer: ModelContainer = {
        let schema = Schema([VerbEntity.self])
        let appGroupID = AppConfig.Constants.appGroupID
        if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            let storageURL = groupURL.appendingPathComponent("Library/Application Support", isDirectory: true)
            if !FileManager.default.fileExists(atPath: storageURL.path) {
                try? FileManager.default.createDirectory(at: storageURL, withIntermediateDirectories: true)
            }
        }

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier(appGroupID)
        )

        // Old builds used @Attribute(.unique) on `base`, which collapsed the catalog.
        // Wipe the store whenever the catalog version is behind so indexes cannot linger.
        let storedVersion = AppConfig.appGroupStore.integer(forKey: WidgetCatalog.versionKey)
        if storedVersion < WidgetCatalog.currentVersion {
            wipeStore(at: modelConfiguration.url)
            AppConfig.appGroupStore.set(0, forKey: WidgetCatalog.versionKey)
            print("🧹 Widget SwiftData store wiped (catalog \(storedVersion) → \(WidgetCatalog.currentVersion))")
        }

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("⚠️ SwiftData migration failed, recreating store: \(error)")
            wipeStore(at: modelConfiguration.url)
            AppConfig.appGroupStore.set(0, forKey: WidgetCatalog.versionKey)
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }()

    private static func wipeStore(at url: URL) {
        let fm = FileManager.default
        let candidates = [
            url,
            URL(fileURLWithPath: url.path + "-shm"),
            URL(fileURLWithPath: url.path + "-wal"),
        ]
        for file in candidates where fm.fileExists(atPath: file.path) {
            try? fm.removeItem(at: file)
        }
    }
}
