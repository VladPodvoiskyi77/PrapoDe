import SwiftUI

struct ResultSection: View {
    var onGoToLeaderboard: () -> Void
    var onGoToSprintRanking: () -> Void
    
    var body: some View {
        SettingsSectionCard(title: L10n.Settings.Section.Results.title) {
            
            Button(action: onGoToLeaderboard) {
                SettingsRow(
                    icon: "trophy.fill",
                    color: .yellow,
                    title: L10n.Settings.Section.Results.description
                ) {
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
                    NavigationChevron()
                }
            }
        }
    }
}
