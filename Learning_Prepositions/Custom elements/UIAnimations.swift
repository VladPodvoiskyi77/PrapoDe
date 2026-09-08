import SwiftUI
import UIKit

enum HapticFeedback {
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    static func lightImpact() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

struct StaggeredMenuAppearance: ViewModifier {
    let index: Int
    let isVisible: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 28)
            .animation(
                .spring(response: 0.52, dampingFraction: 0.78)
                    .delay(Double(index) * 0.07),
                value: isVisible
            )
    }
}

extension View {
    func staggeredMenuAppearance(index: Int, isVisible: Bool) -> some View {
        modifier(StaggeredMenuAppearance(index: index, isVisible: isVisible))
    }
}

struct AnswerCelebrationOverlay: View {
    let isCorrect: Bool

    @State private var isShown = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(isCorrect ? Color.green.opacity(isShown ? 0.55 : 0) : Color.red.opacity(isShown ? 0.4 : 0), lineWidth: 3)
                .scaleEffect(isShown ? 1.02 : 0.98)

            if isCorrect {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56, weight: .semibold))
                    .foregroundStyle(.green)
                    .symbolRenderingMode(.hierarchical)
                    .scaleEffect(isShown ? 1 : 0.4)
                    .opacity(isShown ? 1 : 0)
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            if isCorrect {
                HapticFeedback.success()
            } else {
                HapticFeedback.error()
            }
            withAnimation(.spring(response: 0.38, dampingFraction: 0.62)) {
                isShown = true
            }
            withAnimation(.easeOut(duration: 0.25).delay(0.55)) {
                isShown = false
            }
        }
    }
}

struct ScorePulseModifier: ViewModifier {
    let score: Int

    @State private var pulse = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(pulse ? 1.12 : 1)
            .animation(.spring(response: 0.32, dampingFraction: 0.45), value: pulse)
            .onChange(of: score) { oldValue, newValue in
                guard newValue > oldValue else { return }
                pulse = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    pulse = false
                }
            }
    }
}

extension View {
    func scorePulse(on score: Int) -> some View {
        modifier(ScorePulseModifier(score: score))
    }
}

struct FloatingPlusOneLabel: View {
    var text: String = "+1"
    var color: Color = .green

    @State private var offsetX: CGFloat = 0
    @State private var offsetY: CGFloat = 10
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.5

    var body: some View {
        Text(text)
            .font(.system(size: 32, weight: .heavy, design: .rounded))
            .foregroundStyle(color)
            .shadow(color: .black.opacity(0.12), radius: 2, y: 1)
            .shadow(color: color.opacity(0.4), radius: 8, y: 3)
            .scaleEffect(scale)
            .opacity(opacity)
            .offset(x: offsetX, y: offsetY)
            .allowsHitTesting(false)
            .onAppear {
                withAnimation(.spring(response: 0.18, dampingFraction: 0.62)) {
                    scale = 1.08
                    opacity = 1
                    offsetY = 0
                }
                withAnimation(.easeOut(duration: 0.32).delay(0.08)) {
                    offsetX = 16
                    offsetY = -36
                    opacity = 0
                    scale = 0.9
                }
            }
    }
}
