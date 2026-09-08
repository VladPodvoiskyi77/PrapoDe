import Foundation
import WidgetKit

enum WidgetAnalyticsService {
    static let widgetKind = "PrepoWidget"

    static func sync() {
        flushPendingTimelineMetrics()
        checkWidgetInstallation()
    }

    static func handleWidgetTap(url: URL) {
        guard url.scheme == "prapode", url.host == "widget" else { return }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let verb = components?.queryItems?.first(where: { $0.name == "verb" })?.value ?? "unknown"
        let level = components?.queryItems?.first(where: { $0.name == "level" })?.value ?? "unknown"

        AnalyticsManager.shared.logWidgetTap(verb: verb, level: level)
    }

    private static func flushPendingTimelineMetrics() {
        let metrics = WidgetAnalyticsStore.consumePendingTimelineMetrics()
        guard metrics.refreshCount > 0 else { return }

        AnalyticsManager.shared.logWidgetTimelineRefreshed(
            refreshCount: metrics.refreshCount,
            entryCount: metrics.entryCount
        )
    }

    private static func checkWidgetInstallation() {
        WidgetCenter.shared.getCurrentConfigurations { result in
            guard case .success(let configs) = result else { return }

            let widgetConfigs = configs.filter { $0.kind == widgetKind }
            let count = widgetConfigs.count
            let family = widgetConfigs.first.map { widgetFamilyName($0.family) } ?? "none"
            let previousCount = WidgetAnalyticsStore.lastKnownInstalledCount

            AnalyticsManager.shared.setWidgetInstalled(count > 0)

            if count > previousCount {
                AnalyticsManager.shared.logWidgetInstalled(widgetCount: count, family: family)
            } else if count == 0, previousCount > 0 {
                AnalyticsManager.shared.logWidgetRemoved(previousCount: previousCount)
            }

            WidgetAnalyticsStore.lastKnownInstalledCount = count
        }
    }

    private static func widgetFamilyName(_ family: WidgetFamily) -> String {
        switch family {
        case .systemSmall: return "small"
        case .systemMedium: return "medium"
        case .systemLarge: return "large"
        case .systemExtraLarge: return "extraLarge"
        case .accessoryCircular: return "accessoryCircular"
        case .accessoryRectangular: return "accessoryRectangular"
        case .accessoryInline: return "accessoryInline"
        @unknown default: return "unknown"
        }
    }
}
