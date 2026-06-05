import SwiftUI
struct LanguageSection: View {
    @Binding var selectedLanguageRawValue: String
    @Binding var selectedLevelRawValue: String
    
    var body: some View {
        SettingsSectionCard(title: L10n.Settings.Section.Language.title) {
            
            // 1. Язык
            SettingsRow(
                icon: "globe",
                color: .purple,
                title: L10n.Settings.Section.TranslationLanguage.description
            ) {
                Menu {
                    ForEach(Language.allCases) { lang in
                        Button {
                            withAnimation { selectedLanguageRawValue = lang.rawValue }
                        } label: {
                            // Добавляем галочку и тут для единообразия
                            if selectedLanguageRawValue == lang.rawValue {
                                Label("\(lang.emojiFlag) \(lang.name)", systemImage: "checkmark")
                            } else {
                                Text("\(lang.emojiFlag) \(lang.name)")
                            }
                        }
                    }
                } label: {
                    if let lang = Language(rawValue: selectedLanguageRawValue) {
                        HStack(spacing: 4) {
                            Text("\(lang.emojiFlag) \(lang.name)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary) // ✅ Адаптивный цвет
                            
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
            
            Divider()
                .padding(.leading, 44)
            
            // 2. Уровень
            SettingsRow(
                icon: "chart.bar.fill",
                color: .orange,
                title: L10n.Settings.Section.LanguageLevel.description
            ) {
                Menu {
                    ForEach(Level.allCases) { level in
                        Button {
                            withAnimation { selectedLevelRawValue = level.rawValue }
                        } label: {
                            if selectedLevelRawValue == level.rawValue {
                                Label("\(level.emoji) \(level.id)", systemImage: "checkmark")
                            } else {
                                Text("\(level.emoji) \(level.id)")
                            }
                        }
                    }
                } label: {
                    if let lvl = Level(rawValue: selectedLevelRawValue) {
                        HStack(spacing: 4) {
                            Text("\(lvl.emoji) \(lvl.id)")
                                .font(.subheadline)
                                .foregroundStyle(lvl.color)
                                .fontWeight(.bold)
                            
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
        }
    }
}
