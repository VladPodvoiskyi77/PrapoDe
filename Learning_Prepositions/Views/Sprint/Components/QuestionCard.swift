import SwiftUI

struct QuestionCard: View {
    let item: WordItem
    let isAnswered: Bool
    var isCompactHeight = false

    private var baseFontSize: CGFloat {
        let length = item.example.count
        if isCompactHeight {
            if length > 80 { return 16 }
            if length > 50 { return 18 }
            return 20
        }
        if length > 80 { return 18 }
        if length > 50 { return 20 }
        return 22
    }

    private var cardPadding: CGFloat {
        isCompactHeight ? 16 : 24
    }

    var body: some View {
        let questionText = isAnswered
            ? item.exampleWithHighlighted(word: item.preposition, size: baseFontSize + 2)
            : AttributedString(item.exampleWithHiddenPreposition())

        Text(questionText)
            .font(.system(size: baseFontSize, design: .rounded))
            .fontWeight(.medium)
            .foregroundStyle(.primary)
            .multilineTextAlignment(.center)
            .lineSpacing(isCompactHeight ? 2 : 4)
            .minimumScaleFactor(0.85)
            .padding(cardPadding)
            .frame(maxWidth: .infinity)
            .fixedSize(horizontal: false, vertical: true)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            )
    }
}
