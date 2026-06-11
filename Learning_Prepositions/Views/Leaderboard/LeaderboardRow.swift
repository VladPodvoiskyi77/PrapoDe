import SwiftUI

import SwiftUI

struct LeaderboardRow: View {
    let index: Int
    let result: QuizResult
    
    var rankSymbol: String {
        switch index {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(index)."
        }
    }
    
    var scorePercentage: Int {
        guard result.total > 0 else { return 0 }
        return result.score * 100 / result.total
    }
    
    var body: some View {
        HStack(spacing: 16) {
            
            Text(rankSymbol)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .frame(width: 40)
                    .foregroundStyle(.primary)
            
            VStack(alignment: .leading, spacing: 6) {
                
                HStack(spacing: 8) {
                    Text("\(result.score)/\(result.total)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text("·")
                        .foregroundStyle(.tertiary)
                    
                    if result.gameType == .sprint {
                        HStack(spacing: 4) {
                            Image(systemName: "stopwatch.fill")
                                .font(.caption2)
                            Text(String(format: "%.2fs", result.timeElapsed ?? 0))
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.orange)
                    } else {
                        Text("\(scorePercentage)%")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(scorePercentage >= 80 ? .green : .blue)
                    }
                }
                
                HStack(spacing: 6) {
                    Text(result.category)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(result.date.formatted(date: .numeric, time: .omitted))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                Text(result.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
