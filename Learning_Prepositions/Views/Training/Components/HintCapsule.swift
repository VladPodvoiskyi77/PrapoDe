import SwiftUI

struct HintCapsule: View {
    let text: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
            
            Text(text)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(color)
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(
            Capsule()
                .fill(.white)
                    .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .contentShape(Capsule())
    }
}
