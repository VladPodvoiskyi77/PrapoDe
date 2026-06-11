import SwiftUI

struct QuizSettingsSection: View {
    @Binding var questionCount: Int
    
    var body: some View {
        SettingsSectionCard(title: L10n.Settings.Section.Quiz.title) {
            
            SettingsRow(
                icon: "list.number",
                color: .blue,
                title: L10n.Settings.Section.Quiz.description
            ) {
                Menu {
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
                            .font(.subheadline)
                                .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                        
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
