import SwiftUI

// MARK: - Reusable Button Component

struct AppButton: View {
    var title: String
    var minHeight: CGFloat = 80
    var background: Color = .blue.opacity(0.3)
    var textColor: Color = .black
    private var action: (() -> Void)?

    @State private var isPressed = false

    init(
        title: String,
        minHeight: CGFloat = 80,
        background: Color = .blue.opacity(0.3),
        textColor: Color = .black,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.minHeight = minHeight
        self.background = background
        self.textColor = textColor
        self.action = action
    }

    var body: some View {
        Button(action: {
            action?()
        }) {
            buttonLabel
                .scaleEffect(isPressed ? 0.97 : 1.0)
                .animation(.easeOut(duration: 0.12), value: isPressed)
        }
        .buttonStyle(.plain)
        .onChange(of: isPressed) { oldValue, newValue in
            //print("Changed from \(oldValue) to \(newValue)")
        }
        
        .pressEvents(onPress: {
            withAnimation { isPressed = true }
        }, onRelease: {
            withAnimation { isPressed = false }
        })
    }

    private var buttonLabel: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity, minHeight: minHeight)
            .background(background)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.06), radius: 2, x: 0, y: 1)
            .padding(.horizontal, 4)
    }
}


extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressEventsModifier(onPress: onPress, onRelease: onRelease))
    }
}

private struct PressEventsModifier: ViewModifier {
    let onPress: () -> Void
    let onRelease: () -> Void

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}
