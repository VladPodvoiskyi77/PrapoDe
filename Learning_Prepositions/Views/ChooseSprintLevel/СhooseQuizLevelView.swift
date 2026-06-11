import SwiftUI

struct СhooseQuizLevelView: View {
    @StateObject private var viewModel: СhooseQuizLevelViewModel
    @EnvironmentObject private var nav: NavigationViewModel

    init(items: [WordItem], category: String) {
        _viewModel = StateObject(wrappedValue: СhooseQuizLevelViewModel(items: items, categoryName: category))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text(L10n.СhooseQuizLevel.title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .padding(.top, 60)
                .padding(.horizontal, 24)
            
            VStack(spacing: 16) {
                ForEach(QuizDifficulty.allCases, id: \.self) { mode in
                    MenuCard(
                        title: mode.label,
                        iconName: mode.iconName,
                        iconColor: mode.iconColor,
                        action: {
                            nav.goTo(.speedQuiz(viewModel.wordItems, viewModel.categoryName, mode))
                        }
                    )
                }
                
                MenuCard(
                    title: L10n.WorldRanking.Sprint.title,
                    iconName: "globe.europe.africa.fill",
                    iconColor: .purple,
                    action: {
                        nav.goTo(.globalRanking(.sprint, viewModel.currentLevelRaw, .easy))
                    }
                ).padding(.top, 24)
            }
            .padding(.horizontal, 24)
            
            Spacer()
            }
        .background(
            AppTheme.mainGradient.ignoresSafeArea()
        )
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}


