import SwiftUI

struct InteractionBlockerModifier: ViewModifier {

    let delay: TimeInterval

    @State private var isBlocked = true

    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isBlocked)

            if isBlocked {
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture { }
            }
        }
        .onAppear {
            isBlocked = true

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                isBlocked = false
            }
        }
    }
}
