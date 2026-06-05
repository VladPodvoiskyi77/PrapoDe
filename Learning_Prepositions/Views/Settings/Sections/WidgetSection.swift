import SwiftUI

struct WidgetSection: View {
    // Действия
    var onGoToWidgetWordSelection: () -> Void
    
    var body: some View {
        SettingsSectionCard(title: L10n.Settings.Section.Widget.title) {
            
            // 1. Кнопка Лидерборд
            Button(action: onGoToWidgetWordSelection) {
                SettingsRow(
                    icon: "text.badge.checkmark",
                    color: .red,
                    title: L10n.Settings.Section.Widget.wordSelection
                ) {
                    // Передаем стрелочку как контент
                    NavigationChevron()
                }
            }
        }
    }
}
