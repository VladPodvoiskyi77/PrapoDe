import SwiftUI

struct QuestionCard: View {
    let item: WordItem
    let isAnswered: Bool
    
    var body: some View {
        let questionText = isAnswered
            ? item.exampleWithHighlighted(word: item.preposition)
            : AttributedString(item.exampleWithHiddenPreposition())
        
        Text(questionText)
            .font(.system(.title2, design: .rounded))
            .fontWeight(.medium)
            .foregroundStyle(.primary)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .minimumScaleFactor(0.7)
            .padding(24)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 180)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            )
    }
}
