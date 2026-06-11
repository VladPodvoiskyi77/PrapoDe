import Foundation
import SwiftData

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

        let modelConfiguration = ModelConfiguration(schema: schema,
                                                    isStoredInMemoryOnly: false,
        groupContainer: .identifier(appGroupID))

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
