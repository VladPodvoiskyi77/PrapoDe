import SwiftUI

struct SpeedAnswerGrid: View {
    let options: [String]
    let action: (String) -> Void
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(options, id: \.self) { option in
                Button { action(option) } label: {
                    Text(option)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
