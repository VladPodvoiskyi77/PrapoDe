import SwiftUI

struct ComingSoonView: View {
    let title: String

    var body: some View {
        ZStack {
            AppTheme.mainGradient.ignoresSafeArea()
            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                Text(L10n.ComingSoon.message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
