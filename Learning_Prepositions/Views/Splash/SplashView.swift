import SwiftUI

struct SplashView: View {
    @StateObject private var viewModel = SplashViewModel()
    
    var body: some View {
        ZStack {
            // 1. Компонент фона
            SplashBackgroundView()
            
            // 2. Центральный контент
            VStack(spacing: 20) {
                
                Image(uiImage: Asset.main.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 40))
                    .cornerRadius(60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 60)
                            .stroke(Color.white, lineWidth: 8)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 25, x: 0, y: 12)
                
                // Текст
                VStack(spacing: 12) {
                    Text(AppConfig.Support.appName)
                        .font(.system(size: 54, weight: .black, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                    
                    Text(L10n.Splash.description)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(
                            Capsule()
                                .fill(Color.orange)
                                .shadow(color: Color.orange.opacity(0.4), radius: 8, x: 0, y: 4)
                        )
                }
            }
            .scaleEffect(viewModel.contentScale)
            .opacity(viewModel.contentOpacity)
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}

#Preview {
    SplashView()
}
