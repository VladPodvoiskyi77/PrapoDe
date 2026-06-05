import SwiftUI

struct QuizSettingsSection: View {
    @Binding var questionCount: Int
    
    var body: some View {
        SettingsSectionCard(title: L10n.Settings.Section.Quiz.title) {
            
            // 1. Количество вопросов
            SettingsRow(
                icon: "list.number",
                color: .blue,
                title: L10n.Settings.Section.Quiz.description
            ) {
                Menu {
                    // Используем stride для генерации шагов 5, 10, 15...
                    ForEach(Array(stride(from: 5, through: 30, by: 5)), id: \.self) { count in
                        Button {
                            withAnimation { questionCount = count }
                        } label: {
                            if questionCount == count {
                                Label("\(count)", systemImage: "checkmark")
                            } else {
                                Text("\(count)")
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text("\(questionCount)")
                            .font(.subheadline) // Чуть аккуратнее шрифт
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                        
                        // Используем .tertiary для едва заметной стрелочки
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}
