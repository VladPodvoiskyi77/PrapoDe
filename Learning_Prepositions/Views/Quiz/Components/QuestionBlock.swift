import SwiftUI

struct QuestionBlock: View {
    @ObservedObject var viewModel: QuizViewModel
    let item: WordItem
     

    var body: some View {
        VStack(spacing: 24) { // Увеличил отступ между карточкой и кнопками
            // MARK: - Вопрос
            QuestionCard(item: item, isAnswered: viewModel.isAnswered)
                .id("q_\(item.id)")
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .padding(.horizontal, 8) // Небольшой отступ
            
            // MARK: - Варианты ответов
            let options = viewModel.stableOptions
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(options) { option in
                    Button {
                        viewModel.selectAnswer(option.text)
                    } label: {
                        Text(option.text)
                            .font(.system(.headline, design: .rounded)) // Rounded шрифт
                            .fontWeight(.medium)
                            .foregroundStyle(isColored(option.text) ? .white : .primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5) // 👈 Важно для длинных слов!
                            .frame(maxWidth: .infinity, minHeight: 60) // Кнопки чуть выше (удобнее нажимать)
                            .background(getBackgroundColor(for: option.text))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .disabled(viewModel.isAnswered)
                }
            }
            .padding(.horizontal, 4) // Чуть-чуть отжимаем от краев
        }
    }
    
    // MARK: - Helpers
    
    // Проверяем, окрашена ли кнопка (Правильно/Неправильно)
    private func isColored(_ text: String) -> Bool {
        let color = viewModel.buttonColor(for: text)
        // Если цвет НЕ белый и НЕ прозрачный — значит это результат ответа
        return color != .white && color != .clear
    }
    
    // Умный цвет фона
    private func getBackgroundColor(for text: String) -> Color {
        let vmColor = viewModel.buttonColor(for: text)
        
        // Если ViewModel возвращает белый (стандартный) цвет,
        // мы подменяем его на АДАПТИВНЫЙ системный цвет.
        if vmColor == .white {
            return Color(UIColor.secondarySystemGroupedBackground)
        }
        
        // Иначе возвращаем цвет ответа (Зеленый/Красный)
        return vmColor
    }
}
