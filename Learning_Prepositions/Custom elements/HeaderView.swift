import SwiftUI

struct HeaderView: View {
    let title: String
    @Binding var showExitAlert: Bool
    
    // 1. Добавляем опциональный замыкание для кнопки инфо
    var onInfoAction: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 6) {
            // Левая часть
            if let action = onInfoAction {
                // Если действие передано — показываем кнопку вопроса
                Button(action: action) {
                    infoButtonLabel
                }
            } else {
                // Если действия нет — оставляем невидимую заглушку для центровки
                closeButtonLabel
                    .opacity(0)
                    .accessibilityHidden(true)
            }
            
            Spacer()
            
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Правая часть (кнопка выхода)
            Button {
                showExitAlert = true
            } label: {
                closeButtonLabel
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .navigationBarBackButtonHidden(true)
    }
    
    // Дизайн кнопки выхода
    private var closeButtonLabel: some View {
        Image(systemName: "xmark")
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.secondary)
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .clipShape(Circle())
    }
    
    // Дизайн кнопки информации (в том же стиле)
    private var infoButtonLabel: some View {
        Image(systemName: "questionmark.circle")
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.secondary)
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .clipShape(Circle())
    }
}
