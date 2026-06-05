import SwiftUI

struct WidgetSelectionHeaderView: View {
    let selectedCount: Int
    let totalCount: Int
    let level: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.WidgetWord.Header.description)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(selectedCount)")
                        .font(.title.bold())
                        .foregroundColor(.white)
                    Text("/ \(totalCount)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            Spacer()
            Text(level)
                .font(.system(size: 50, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.15), radius: 2, x: 2, y: 2)
        }
        .padding(24)
        .background(AppTheme.linearGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: AppTheme.cardShadow.opacity(0.4), radius: 12, x: 0, y: 8)
    }
}

