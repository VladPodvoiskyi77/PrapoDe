import SwiftUI

struct SpeedQuizHeader: View {
    let timeRemaining: TimeInterval
    let totalTime: TimeInterval
    let score: Int
    
    var body: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "timer")
                Text(timeRemaining, format: .number.precision(.fractionLength(2)))
            }
            .font(.headline)
            .foregroundColor(timeRemaining <= 10 ? .red : .primary)
            .padding(10)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(10)
            .shadow(radius: 1)
            
            Spacer()
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.gray.opacity(0.2))
                    Capsule()
                        .fill(timeRemaining <= 10 ? Color.red : Color.blue)
                        .frame(width: geo.size.width * (timeRemaining / totalTime))
                        .animation(.linear(duration: 1), value: timeRemaining)
                }
            }
            .frame(height: 8)
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "star.fill").foregroundColor(.yellow)
                Text("\(score)")
            }
            .font(.headline)
            .padding(10)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(10)
            .shadow(radius: 1)
        }
    }
    
    private func timeString(time: TimeInterval) -> String {
        String(format: "%02d:%02d", Int(time)/60, Int(time)%60)
    }
}
