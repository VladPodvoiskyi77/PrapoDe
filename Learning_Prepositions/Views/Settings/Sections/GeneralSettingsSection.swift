import SwiftUI

struct GeneralSettingsSection: View {
    // Действия
    var onSendFeedback: () -> Void
    var onGoToAboutApp: () -> Void
    var onResetProgress: () -> Void
    
    var body: some View {
        SettingsSectionCard(title: L10n.Settings.Section.General.title) {
            
            // 1. О приложении
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
            
            // 2. Обратная связь
            Button(action: onSendFeedback) {
                SettingsRow(
                    icon: "envelope.fill",
                    color: .green,
                    title: L10n.Settings.Section.Feedback.description
                ) {
                    // Для внешних ссылок часто используют такую иконку
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .fontWeight(.semibold)
                }
            }
            
            Divider()
                .padding(.leading, 44)
            
            // 3. Сброс прогресса
            Button(action: onResetProgress) {
                SettingsRow(
                    icon: "trash.fill",
                    color: .red,
                    title: L10n.Settings.Section.ResetProgress.description
                ) {
                    // Тут ничего не нужно (пустота справа)
                    EmptyView()
                }
            }
            // Маленький хак: делаем текст красным, чтобы показать опасность
            .foregroundStyle(.red)
        }
    }
    
    // Вспомогательный компонент для стрелочки (чтобы не дублировать код)
    @ViewBuilder
    private func NavigationChevron() -> some View {
        Image(systemName: "chevron.right")
            .font(.caption)
            .foregroundStyle(.tertiary) // Едва заметный серый (адаптивный)
            .fontWeight(.semibold)
    }
}
