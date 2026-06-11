import SwiftUI

enum WordRowMode {
    case learning(score: Int, isLearned: Bool)
    case selection(isOn: Binding<Bool>)}

// MARK: - Карточка слова
struct WordRowView: View {
    let base: String
    let preposition: String
    let translation: String
    let caseType: String
    let mode: WordRowMode
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 0) {
                    Text(base)
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text(" " + preposition)
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                Text(translation)
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            
            Spacer()
            
            if !caseType.isEmpty {
                Text(caseType.prefix(3).uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(caseColor.opacity(0.15))
                    .foregroundColor(caseColor)
                    .clipShape(Capsule())
            }
            
            rightSideView
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    @ViewBuilder
    private var rightSideView: some View {
        switch mode {
        case .learning(let score, let isLearned):
            if isLearned {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            } else {
                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { index in
                        Circle()
                            .fill(index < score ? Color.orange : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
            }
            
        case .selection(let isOn):
            Toggle("", isOn: isOn)
                .labelsHidden()
                    .tint(.orange)
                }
    }
    
    private var caseColor: Color {
        let type = caseType.lowercased()
        if type.contains("akk") { return .pink }
        else if type.contains("dat") { return .indigo }
        else if type.contains("gen") { return .teal }
        return .gray
    }
}
