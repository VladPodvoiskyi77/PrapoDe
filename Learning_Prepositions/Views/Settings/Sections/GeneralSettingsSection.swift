import SwiftUI

struct GeneralSettingsSection: View {
    var onSendFeedback: () -> Void
    var onGoToAboutApp: () -> Void
    var onResetProgress: () -> Void
    
    var body: some View {
        SettingsSectionCard(title: L10n.Settings.Section.General.title) {
            
            Button(action: onGoToAboutApp) {
                SettingsRow(
                    icon: "info.circle.fill",
                    color: .blue,
                    title: L10n.About.title
                ) {
                    NavigationChevron()
                }
            }
            
            Divider()
                .padding(.leading, 44)
            
            Button(action: onSendFeedback) {
                SettingsRow(
                    icon: "envelope.fill",
                    color: .green,
                    title: L10n.Settings.Section.Feedback.description
                ) {
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .fontWeight(.semibold)
                }
            }
            
            Divider()
                .padding(.leading, 44)
            
            Button(action: onResetProgress) {
                SettingsRow(
                    icon: "trash.fill",
                    color: .red,
                    title: L10n.Settings.Section.ResetProgress.description
                ) {
                    EmptyView()
                }
            }
            .foregroundStyle(.red)
        }
    }
    
    @ViewBuilder
    private func NavigationChevron() -> some View {
        Image(systemName: "chevron.right")
            .font(.caption)
            .foregroundStyle(.tertiary) // Едва заметный серый (адаптивный)
            .fontWeight(.semibold)
    }
}
