import SwiftUI

// MARK: - Компонент: Карточка вопроса
struct QuizReviewCard: View {
    let item: AnswerResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.base)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(item.prepositionTranslation)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(item.caseType)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(item.caseType.caseColor.opacity(0.1))
                    .foregroundColor(item.caseType.caseColor)
                    .cornerRadius(6)
            }
            .padding()
            
            Divider()
                .padding(.leading)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "text.quote")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 2)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.example)
                            .font(.system(.body, design: .serif))
                            .italic()
                            .foregroundColor(.primary.opacity(0.8))
                        
                        Text(item.exampleTranslation)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            
            HStack {
                if item.isCorrect {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text(L10n.QuizReview.yourAnswer + " \(item.usersAnswer)")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.green)
                } else {
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                            Text(item.usersAnswer)
                                .strikethrough()
                        }
                        .foregroundColor(.red)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .foregroundColor(.gray)
                            .font(.caption)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Text(item.preposition)
                                .fontWeight(.bold)
                            Image(systemName: "checkmark.circle.fill")
                        }
                        .foregroundColor(.green)
                    }
                }
            }
            .font(.subheadline)
            .padding()
            .background(item.isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(item.isCorrect ? Color.green.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}
