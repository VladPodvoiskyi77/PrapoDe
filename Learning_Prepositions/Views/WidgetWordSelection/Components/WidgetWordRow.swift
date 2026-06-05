import SwiftUI
import SwiftData

struct WidgetWordRow: View {
    let word: VerbEntity
    let language: Language
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(word.base)
                    .font(.headline)
                
                Text(word.preposition)
                    .font(.headline)
                    // Твоё расширение для цвета падежа
                    .foregroundColor(word.caseTypeRaw.caseColor)
            }
            
            // Твой метод получения перевода
            Text(word.getTranslation(for: language))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}
