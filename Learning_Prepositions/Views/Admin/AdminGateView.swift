import SwiftUI

struct AdminGateView: View {
    @Binding var isPresented: Bool

    @State private var digits = ""
    @State private var unlocked = false
    @State private var isChecking = false
    @State private var page: AdminPage = .menu
    @State private var shakeOffset: CGFloat = 0
    @State private var rejectFlash = false

    var body: some View {
        ZStack {
            AppTheme.mainGradient
                .ignoresSafeArea()
                .blur(radius: 28)

            Color.black.opacity(0.38)
                .ignoresSafeArea()

            if unlocked {
                switch page {
                case .menu:
                    AdminDashboardView(onOpen: { page = $0 })
                case .registrations:
                    AdminRecentUsersView(onBack: { page = .menu })
                case .results:
                    AdminRecentResultsView(onBack: { page = .menu })
                case .countries:
                    AdminCountriesView(onBack: { page = .menu })
                case .daily:
                    AdminDailyAnalyticsView(onBack: { page = .menu })
                }
            } else {
                pinContent
            }

            VStack {
                HStack {
                    Spacer()
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.85))
                            .padding(10)
                            .background(Circle().fill(.white.opacity(0.16)))
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 12)
                }
                Spacer()
            }
        }
    }

    private var pinContent: some View {
        VStack(spacing: 36) {
            HStack(spacing: 18) {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(dotFill(index))
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle().stroke(.white.opacity(0.55), lineWidth: 1)
                        )
                }
            }
            .offset(x: shakeOffset)

            if isChecking {
                ProgressView()
                    .tint(.white)
            } else {
                VStack(spacing: 14) {
                    ForEach(keyRows, id: \.self) { row in
                        HStack(spacing: 18) {
                            ForEach(row, id: \.self) { key in
                                keyButton(key)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 32)
    }

    private var keyRows: [[String]] {
        [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], ["", "0", "⌫"]]
    }

    private func dotFill(_ index: Int) -> Color {
        if rejectFlash {
            return .red.opacity(0.85)
        }
        return index < digits.count ? .white : .white.opacity(0.18)
    }

    @ViewBuilder
    private func keyButton(_ key: String) -> some View {
        if key.isEmpty {
            Color.clear.frame(width: 72, height: 72)
        } else {
            Button {
                handleKey(key)
            } label: {
                Text(key)
                    .font(.system(size: key == "⌫" ? 22 : 26, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 72, height: 72)
                    .background(Circle().fill(.white.opacity(0.16)))
            }
            .buttonStyle(.plain)
            .disabled(isChecking)
        }
    }

    private func handleKey(_ key: String) {
        if key == "⌫" {
            if !digits.isEmpty {
                digits.removeLast()
            }
            return
        }
        guard digits.count < 4 else { return }
        digits.append(key)
        guard digits.count == 4 else { return }
        submit()
    }

    private func submit() {
        let attempt = digits
        isChecking = true
        Task {
            do {
                try await AdminStatsService.unlock(passcode: attempt)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                withAnimation(.easeOut(duration: 0.2)) {
                    unlocked = true
                }
            } catch {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                rejectFlash = true
                withAnimation(.default.repeatCount(3, autoreverses: true)) {
                    shakeOffset = 10
                }
                try? await Task.sleep(nanoseconds: 350_000_000)
                shakeOffset = 0
                rejectFlash = false
                digits = ""
            }
            isChecking = false
        }
    }
}
