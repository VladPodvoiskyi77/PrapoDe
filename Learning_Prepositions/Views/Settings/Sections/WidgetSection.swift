import SwiftUI

struct WidgetSection: View {
    var onGoToWidgetWordSelection: () -> Void
    
    var body: some View {
        SettingsSectionCard(title: L10n.Settings.Section.Widget.title) {
            
            Button(action: onGoToWidgetWordSelection) {
                SettingsRow(
                    icon: "text.badge.checkmark",
                    color: .red,
                    title: L10n.Settings.Section.Widget.wordSelection
                ) {
                    NavigationChevron()
                }
            }
        }
    }
}
