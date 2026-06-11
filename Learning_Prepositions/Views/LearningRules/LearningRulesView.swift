import SwiftUI

struct LearningRulesView: View {
    @Environment(\.dismiss) var dismiss
    let context: RulesContext    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                Text(context.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .padding(.top, 20)
                
                ForEach(context.items) { rule in
                    InfoRow(
                        icon: rule.icon,
                        color: rule.color,
                        title: rule.title,
                        text: rule.description
                    )
                }
                
                Spacer(minLength: 40)
                
                Button {
                    dismiss()
                } label: {
                    Text(L10n.Rules.Button.close)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                .padding(.bottom, 20)
            }
            .padding(24)
        }
    }
}
