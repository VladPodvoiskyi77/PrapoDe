import SwiftUI

struct SettingsRow<RightContent: View>: View {
    let icon: String
    let color: Color
    let title: String
    let showChevron: Bool
    let rightContent: RightContent
    
    init(
        icon: String,
        color: Color,
        title: String,
        showChevron: Bool = false,
        @ViewBuilder rightContent: () -> RightContent = { EmptyView() }
    ) {
        self.icon = icon
        self.color = color
        self.title = title
        self.showChevron = showChevron
        self.rightContent = rightContent()
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            Text(title)
                .font(.system(size: 17))
                .foregroundStyle(AppTheme.primaryText)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)
            
            Spacer(minLength: 8)
            
            rightContent
                .layoutPriority(2)
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.gray.opacity(0.5))
            }
        }
        .padding(16)
    }
}
