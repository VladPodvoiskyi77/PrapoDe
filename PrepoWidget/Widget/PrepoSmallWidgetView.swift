import WidgetKit
import SwiftUI

struct PrepoSmallWidgetView: View {
    var entry: SimpleEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Image("mainWidget")
                    .resizable()
                    .frame(width: 54, height: 54)
                    .cornerRadius(12)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    Text(entry.verbItem.caseTypeRaw)
                        .font(.system(size: 8, weight: .black))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(.white.opacity(0.2))
                        .clipShape(Capsule())
                    
                    Text(entry.languageCode.rawValue)
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(RoundedRectangle(cornerRadius: 8).fill(.black.opacity(0.2)))
                }
            }
            
            Spacer(minLength: 6)
            
            Text(entry.verbItem.basePreposition)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            
            Text(entry.verbItem.getTranslation(for: entry.languageCode))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
                .lineLimit(2)
            
            Spacer(minLength: 0)
        }
        .padding(12)
        .containerBackground(entry.verbItem.caseColor.gradient, for: .widget)
    }
}
