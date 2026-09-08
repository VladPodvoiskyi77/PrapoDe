import SwiftUI

struct WritingHintCard: View {
    let result: WritingResult
    let title: String
    let attributedMessage: AttributedString
    let otherVariants: [String]
    
    let alsoText: String
    let correctVariantsText: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: feedbackIcon)
                .font(.system(size: 32))
                .foregroundColor(feedbackColor)
                .symbolRenderingMode(.hierarchical)            
            VStack(alignment: .leading, spacing: 6) {
                Text(title.uppercased())
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.secondary)
                
                if !attributedMessage.characters.isEmpty {
                    Text(attributedMessage)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                
                if !otherVariants.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text((result == .wrong || result == .skipped) ? correctVariantsText : alsoText)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        ForEach(Array(otherVariants.enumerated()), id: \.offset) { _, variant in
                            Text("• \(variant)")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal, 24)
    }

    private var feedbackIcon: String {
        switch result {
        case .perfect: return "checkmark.circle.fill"
        case .missingUmlaut, .extraUmlaut: return "exclamationmark.bubble.fill"
        case .wrong: return "xmark.circle.fill"
        case .skipped: return "arrow.forward.circle.fill"
        }
    }

    private var feedbackColor: Color {
        switch result {
        case .perfect: return .green
        case .missingUmlaut, .extraUmlaut: return .orange
        case .wrong: return .red
        case .skipped: return .secondary
        }
    }
}
