import SwiftUI

struct ResultSection: View {
    // Действия
    var onGoToLeaderboard: () -> Void
    var onGoToSprintRanking: () -> Void
    
    var body: some View {
        SettingsSectionCard(title: L10n.Settings.Section.Results.title) {
            
            // 1. Кнопка Лидерборд
            Button(action: onGoToLeaderboard) {
                SettingsRow(
                    icon: "trophy.fill",
                    color: .yellow,
                    title: L10n.Settings.Section.Results.description
                ) {
                    // Передаем стрелочку как контент
                    NavigationChevron()
                }
            }
            
            Divider()
                .padding(.leading, 44)
            
            Button(action: onGoToSprintRanking) {
                SettingsRow(
                    icon: "globe.europe.africa.fill",
                    color: .purple,
                    title: L10n.WorldRanking.Sprint.title
                ) {
                    // Передаем стрелочку как контент
                    NavigationChevron()
                }
            }
        }
    }
}
