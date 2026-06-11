import SwiftUI

struct AboutAppView: View {
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                
                VStack(spacing: 16) {
                    Image(uiImage: Asset.main.image)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .cornerRadius(22)
                        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                    
                    VStack(spacing: 4) {
                        Text(AppConfig.Support.appName)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                    }
                }
                .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 24) {
                    
                    Text(L10n.About.intro)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Divider()
                    
                    Text(L10n.About.Why.title)
                        .font(.title3)
                        .bold()
                    

                        FeatureRow(icon: "rectangle.stack.fill", color: .blue,
                                   title: L10n.About.Feature1.title, text: L10n.About.Feature1.text)
                        
                        FeatureRow(icon: "book.closed.fill", color: .cyan,
                                   title: L10n.About.FeatureTraining.title, text: L10n.About.FeatureTraining.text)

                        FeatureRow(icon: "checkmark.circle.fill", color: .green,
                                   title: L10n.About.FeatureQuiz.title, text: L10n.About.FeatureQuiz.text)
                        
                        FeatureRow(icon: "bolt.fill", color: .yellow,
                                   title: L10n.About.Feature2.title, text: L10n.About.Feature2.text)
                        
                        FeatureRow(icon: "pencil.and.outline", color: .orange,
                                   title: L10n.About.FeatureWriting.title, text: L10n.About.FeatureWriting.text)

                        FeatureRow(icon: "eye.fill", color: .red,
                                   title: L10n.About.FeatureAnalysis.title, text: L10n.About.FeatureAnalysis.text)
                        
                        FeatureRow(icon: "brain.head.profile", color: .purple,
                                   title: L10n.About.Feature3.title, text: L10n.About.Feature3.text)

                        FeatureRow(icon: "square.grid.2x2.fill", color: .indigo,
                                   title: L10n.About.Feature6.title, text: L10n.About.Feature6.text)
                        
                        FeatureRow(icon: "trophy.fill", color: .yellow,
                                   title: L10n.About.Feature5.title, text: L10n.About.Feature5.text)
                        
                        FeatureRow(icon: "chart.bar.xaxis", color: .teal,
                                   title: L10n.About.Feature4.title, text: L10n.About.Feature4.text)
                    
                    Divider()
                    
                    Text(L10n.About.outro)
                        .font(.body)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .padding(.horizontal)
                
                Text(L10n.About.version + appVersion)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle(L10n.About.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
