import Foundation

enum WidgetAnalyticsStore {
    private static var store: UserDefaults? {
        UserDefaults(suiteName: AppConfig.Constants.appGroupID)
    }

    private enum Keys {
        static let pendingTimelineRefreshes = "widget_pending_timeline_refreshes"
        static let pendingTimelineEntries = "widget_pending_timeline_entries"
        static let lastKnownInstalledCount = "widget_last_known_installed_count"
    }

    static func recordTimelineRefresh(entryCount: Int) {
        guard let store else { return }
        store.set(store.integer(forKey: Keys.pendingTimelineRefreshes) + 1, forKey: Keys.pendingTimelineRefreshes)
        store.set(store.integer(forKey: Keys.pendingTimelineEntries) + max(entryCount, 0), forKey: Keys.pendingTimelineEntries)
    }

    static func consumePendingTimelineMetrics() -> (refreshCount: Int, entryCount: Int) {
        guard let store else { return (0, 0) }
        let refreshes = store.integer(forKey: Keys.pendingTimelineRefreshes)
        let entries = store.integer(forKey: Keys.pendingTimelineEntries)
        store.set(0, forKey: Keys.pendingTimelineRefreshes)
        store.set(0, forKey: Keys.pendingTimelineEntries)
        return (refreshes, entries)
    }

    static var lastKnownInstalledCount: Int {
        get { store?.integer(forKey: Keys.lastKnownInstalledCount) ?? 0 }
        set { store?.set(newValue, forKey: Keys.lastKnownInstalledCount) }
    }
}
