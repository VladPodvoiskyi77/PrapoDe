import SwiftUI

struct QuestionBlock: View {
    @ObservedObject var viewModel: QuizViewModel
    let item: WordItem
     

    var body: some View {
        VStack(spacing: 24) {
            // MARK: - Вопрос
            ZStack {
                QuestionCard(item: item, isAnswered: viewModel.isAnswered)
                    .id("q_\(item.id)")

                if viewModel.isAnswered {
                    AnswerCelebrationOverlay(
                        isCorrect: viewModel.selectedAnswer == item.preposition
                    )
                }
            }
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
            .padding(.horizontal, 8)
            
            // MARK: - Варианты ответов
            let options = viewModel.stableOptions
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(options) { option in
                    Button {
                        viewModel.selectAnswer(option.text)
                    } label: {
                        Text(option.text)
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundStyle(isColored(option.text) ? .white : .primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .background(getBackgroundColor(for: option.text))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(viewModel.isAnswered)
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    // MARK: - Helpers
    
    private func isColored(_ text: String) -> Bool {
        let color = viewModel.buttonColor(for: text)
        // Если цвет НЕ белый и НЕ прозрачный — значит это результат ответа
        return color != .white && color != .clear
    }
    
    private func getBackgroundColor(for text: String) -> Color {
        let vmColor = viewModel.buttonColor(for: text)
        
        // мы подменяем его на АДАПТИВНЫЙ системный цвет.
        if vmColor == .white {
            return Color(UIColor.secondarySystemGroupedBackground)
        }
        
        return vmColor
    }
}
