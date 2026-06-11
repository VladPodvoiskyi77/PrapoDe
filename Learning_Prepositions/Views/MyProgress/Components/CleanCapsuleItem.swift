import SwiftUI

struct CleanCapsuleItem: View {
    let preposition: String
    let isSelected: Bool
    let action: () -> Void
    
    var iconString: String {
        let allTitle = L10n.MyProgress.Capsule.All.title
        
        if preposition == allTitle {
            return "∞"
        }
        
        return String(preposition.prefix(1)).uppercased()
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                
                Text(iconString)
                    .font(.system(size: iconString == "∞" ? 28 : 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(isSelected ? AnyShapeStyle(AppTheme.mainGradient) : AnyShapeStyle(.white))
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(isSelected ? .white.opacity(0.2) : .white.opacity(0.1))
                    )
                    .padding(.bottom, iconString == "∞" ? 2 : 0)
                
                if isSelected {
                    Text(preposition)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black.opacity(0.8))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .padding(.horizontal, 4)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(width: isSelected ? 85 : 60, height: isSelected ? 130 : 60)
            
            .background(
                AppTheme.linearGradient
            )
            .clipShape(Capsule())
            .overlay(
                Capsule().strokeBorder(.white.opacity(isSelected ? 0.8 : 0.3), lineWidth: 1)
            )
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isSelected)
    }
}
