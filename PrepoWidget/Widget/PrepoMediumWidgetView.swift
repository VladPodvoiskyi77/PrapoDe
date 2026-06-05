import WidgetKit
import SwiftUI

struct PrepoMediumWidgetView: View {
    var entry: SimpleEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // --- ВЕРХНЯЯ ЧАСТЬ ---
            HStack(alignment: .top, spacing: 12) {
                
                // 1. Иконка (фиксированный размер)
                Image("mainWidget")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 72, height: 72)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                
                // 2. КОНТЕНТНАЯ КОЛОНКА
                VStack(alignment: .leading, spacing: 0) {
                    
                    // ЛИНИЯ 1: Метаданные (Уровень + Падеж)
                    // Ограничиваем высоту этой строки, чтобы она не "съедала" пространство
                    HStack(spacing: 4) {
                        Text(entry.verbItem.levelRaw)
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(4)
                        
                        Text(entry.verbItem.caseTypeRaw)// shortCaseName.uppercased())
                            .font(.system(size: 9, weight: .heavy))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                    .foregroundColor(.white)
                    .padding(.bottom, 4)
                    
                    // ЛИНИЯ 2: Глагол + Предлог
                    Text(entry.verbItem.basePreposition)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .layoutPriority(2)
                    
                    // ЛИНИЯ 3: Перевод
                    // Теперь он тоже яркий и крупный
                    Text(entry.verbItem.getTranslation(for: entry.languageCode))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.95))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .layoutPriority(1)
                }
                
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding([.horizontal, .top], 0)
            
            Spacer(minLength: 8)
            
            Text(entry.verbItem.exampleSentence)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.95))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.horizontal, .bottom], 0)
                .minimumScaleFactor(0.7)
        }
        .containerBackground(entry.verbItem.caseColor.gradient, for: .widget)
    }
}
