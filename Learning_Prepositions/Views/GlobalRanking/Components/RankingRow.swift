import SwiftUI

struct RankingRow: View {
    let rank: Int
    let entry: GlobalRankingEntry
    private let brandColor = Color(hex: "796fc8")
    
    var body: some View {
        HStack(spacing: 12) {
            rankCircle
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.userName)
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                HStack(alignment: .top, spacing: 6) {
                    Text(entry.countryFlag)
                        .font(.system(size: 18))
                    
                    Text(entry.category)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(brandColor)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(brandColor.opacity(0.1))
                        .cornerRadius(5)
                        .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        }
            }
            .layoutPriority(1)            
            Spacer(minLength: 5)
            
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 3) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.green)
                    Text("\(entry.score)/\(entry.total)")
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundColor(.black)
                }
                
                Text("\(entry.formattedTime)s")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(brandColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(brandColor.opacity(0.06))
                    .cornerRadius(4)
            }
        }
        .padding(.all, 14)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var rankCircle: some View {
        ZStack {
            if rank <= 3 {
                Circle()
                    .fill(medalColor(for: rank).opacity(0.15))
                    .frame(width: 38, height: 38)
                Text(medalEmoji(for: rank)).font(.system(size: 20))
            } else {
                Text("\(rank)")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundColor(.gray.opacity(0.4))
                    .frame(width: 38)
            }
        }
    }
    
    private func medalColor(for rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .clear
        }
    }
    
    private func medalEmoji(for rank: Int) -> String {
        switch rank { case 1: return "🥇" case 2: return "🥈" case 3: return "🥉" default: return "" }
    }
}
