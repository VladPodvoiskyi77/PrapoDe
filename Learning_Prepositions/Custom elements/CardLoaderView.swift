import SwiftUI

struct PrepositionLoaderItem: Identifiable, Equatable {
    let id = UUID()
    let preposition: String
    let contextTop: String
    let contextBottom: String
    let caseLabel: String
    let accentColor: Color
    let isWechsel: Bool

    static let defaultCycle: [PrepositionLoaderItem] = [
        PrepositionLoaderItem(
            preposition: "mit",
            contextTop: "sprechen",
            contextBottom: "dir",
            caseLabel: "Dat.",
            accentColor: .green,
            isWechsel: false
        ),
        PrepositionLoaderItem(
            preposition: "für",
            contextTop: "danken",
            contextBottom: "die Hilfe",
            caseLabel: "Akk.",
            accentColor: .blue,
            isWechsel: false
        ),
        PrepositionLoaderItem(
            preposition: "in",
            contextTop: "gehen",
            contextBottom: "die Stadt",
            caseLabel: "Wechsel",
            accentColor: .blue,
            isWechsel: true
        ),
        PrepositionLoaderItem(
            preposition: "von",
            contextTop: "träumen",
            contextBottom: "dir",
            caseLabel: "Dat.",
            accentColor: .green,
            isWechsel: false
        ),
        PrepositionLoaderItem(
            preposition: "auf",
            contextTop: "warten",
            contextBottom: "dich",
            caseLabel: "Akk.",
            accentColor: .blue,
            isWechsel: false
        ),
        PrepositionLoaderItem(
            preposition: "bei",
            contextTop: "helfen",
            contextBottom: "dir",
            caseLabel: "Dat.",
            accentColor: .green,
            isWechsel: false
        ),
    ]
}

private enum LoaderPhase {
    case entering
    case visible
    case exiting
}

struct CardLoaderView: View {
    var items: [PrepositionLoaderItem] = PrepositionLoaderItem.defaultCycle

    @State private var currentIndex = 0
    @State private var phase: LoaderPhase = .entering
    @State private var wechselShift = false

    private var currentItem: PrepositionLoaderItem {
        items[currentIndex % max(items.count, 1)]
    }

    var body: some View {
        VStack(spacing: 14) {
            loaderCard
            progressDots
        }
        .task(id: items.map(\.preposition)) {
            await animationLoop()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                wechselShift.toggle()
            }
        }
    }

    private var loaderCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, y: 6)

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(AnyShapeStyle(strokeStyle), lineWidth: 3)

            VStack(spacing: 10) {
                Text(currentItem.contextTop)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .opacity(contextOpacity)

                Text(currentItem.preposition)
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(AnyShapeStyle(prepositionStyle))
                    .offset(y: prepositionOffset)
                    .scaleEffect(prepositionScale)
                    .opacity(prepositionOpacity)

                Text(currentItem.contextBottom)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .opacity(contextOpacity)

                Text(currentItem.caseLabel)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(currentItem.isWechsel ? Color.primary : currentItem.accentColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(currentItem.accentColor.opacity(currentItem.isWechsel ? 0.12 : 0.15))
                    )
                    .opacity(contextOpacity)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 22)
        }
        .frame(width: 168, height: 196)
    }

    private var strokeStyle: LinearGradient {
        if currentItem.isWechsel {
            LinearGradient(
                colors: wechselShift ? [.blue, .green] : [.green, .blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            LinearGradient(
                colors: [currentItem.accentColor.opacity(0.65), currentItem.accentColor.opacity(0.35)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var prepositionStyle: LinearGradient {
        if currentItem.isWechsel {
            LinearGradient(
                colors: wechselShift ? [.blue, .green] : [.green, .blue],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            LinearGradient(
                colors: [currentItem.accentColor, currentItem.accentColor.opacity(0.75)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var prepositionOffset: CGFloat {
        switch phase {
        case .entering: 22
        case .visible: 0
        case .exiting: -24
        }
    }

    private var prepositionOpacity: Double {
        switch phase {
        case .entering: 0.25
        case .visible: 1
        case .exiting: 0
        }
    }

    private var prepositionScale: CGFloat {
        switch phase {
        case .entering: 0.82
        case .visible: 1
        case .exiting: 1.08
        }
    }

    private var contextOpacity: Double {
        phase == .visible ? 1 : 0.45
    }

    private var progressDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { dot in
                Circle()
                    .fill(Color.white.opacity(activeDot(for: dot) ? 0.95 : 0.35))
                    .frame(width: activeDot(for: dot) ? 8 : 6, height: activeDot(for: dot) ? 8 : 6)
                    .animation(.easeInOut(duration: 0.25), value: phase)
            }
        }
    }

    private func activeDot(for index: Int) -> Bool {
        switch phase {
        case .entering: index == 0
        case .visible: index == 1
        case .exiting: index == 2
        }
    }

    private func animationLoop() async {
        guard !items.isEmpty else { return }

        while !Task.isCancelled {
            await runPhase(.entering, animation: .spring(response: 0.42, dampingFraction: 0.76), duration: 0.34)
            await runPhase(.visible, animation: .easeOut(duration: 0.2), duration: 0.52)
            await runPhase(.exiting, animation: .easeIn(duration: 0.22), duration: 0.24)

            await MainActor.run {
                currentIndex = (currentIndex + 1) % items.count
            }
        }
    }

    @MainActor
    private func runPhase(_ newPhase: LoaderPhase, animation: Animation, duration: TimeInterval) async {
        withAnimation(animation) {
            phase = newPhase
        }
        try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
    }
}

#Preview {
    ZStack {
        AppTheme.mainGradient.ignoresSafeArea()
        CardLoaderView()
    }
}
