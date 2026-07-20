import SwiftUI
import SwiftData

// MARK: - ViewModel (MVVM)
final class NavigationViewModel: ObservableObject {
    @Published var path = NavigationPath()
    
    @Published var selectedMode: Activity = .training
    
    func goTo(_ screen: Screen) {
        print("👉 Navigating to \(screen.nameScreen) Screen")
        path.append(screen)
    }
    
    func backToRoot() {
        path = NavigationPath()
    }
}

// MARK: - Enum маршрутов
enum Screen: Hashable {
    case activity(Category)
    case mode(Category, Activity)
    case quiz([WordItem], [WordItem], String)
    case result(QuizResultContext)
    case settings
    case leaderboard(ResultContext)
    case training([WordItem], [WordItem], Category)
    case speedQuiz([WordItem], String, QuizDifficulty)
    case chooseQuizLevel ([WordItem], String)
    case analysis([AnswerResult])
    case myProgress(Category)
    case aboutApp
    case writing ([WordItem], Category)
    case onboardingProfile
    case globalRanking(GameType, String, QuizDifficulty)
    case widgetWordSelection
    case prepositionsList
    case prepositionDetail(String, String, String)
    
    var nameScreen: String {
        switch self {
            
        case .activity(_):
            "Activity"
        case .mode(_, _):
            "Mode"
        case .quiz(_, _, _):
            "Quiz"
        case .result(_):
            "Result"
        case .settings:
            "Settings"
        case .leaderboard(_):
            "Leaderboard"
        case .training(_, _, _):
            "Training"
        case .speedQuiz(_, _, _):
            "SpeedQuiz"
        case .chooseQuizLevel(_, _):
            "ChooseQuizLevel"
        case .analysis(_):
            "Analysis"
        case .myProgress(_):
            "MyProgress"
        case .aboutApp:
            "AboutApp"
        case .writing(_, _):
            "Writing"
        case .onboardingProfile:
            "OnboardingProfile"
        case .globalRanking(_, _, _):
            "GlobalRanking"
        case .widgetWordSelection:
            "WidgetWordSelection"
        case .prepositionsList:
            "PrepositionsList"
        case .prepositionDetail(_, _, _):
            "PrepositionDetail"
        }
    }
}

// MARK: - Root View
struct RootView: View {
    @StateObject private var navModel = NavigationViewModel()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            NavigationStack(path: $navModel.path) {
                UniversalMenuView(type: .main, category: .adjektive)
                    .environmentObject(navModel)
                    .navigationDestination(for: Screen.self) { screen in
                        switch screen {
                        case .activity(let category):
                            UniversalMenuView(type: .activity, category: category).environmentObject(navModel)
                        case .mode(let category, let appMode):
                            ModeView(category: category, appMode: appMode)
                                .environmentObject(navModel)
                        case .quiz(let words, let filteredItem, let category):
                            QuizView(items: words, filteredItem: filteredItem, categoryName: category)
                                .environmentObject(navModel)
                        case .training(let allWords, let deckWords, let category):
                            TrainingView(allWords: allWords, deckWords: deckWords, category: category)
                                .environmentObject(navModel)
                        case .result(let quizResultContext):
                            ResultView(quizResultContext: quizResultContext)
                                .environmentObject(navModel)
                        case .settings:
                            SettingsView().environmentObject(navModel)
                        case .leaderboard(let resultContext):
                            LeaderboardView(resultContext: resultContext).environmentObject(navModel)
                        case .speedQuiz(let words, let category, let quizDifficulty):
                            SpeedQuizView(items: words, category: category, difficulty: quizDifficulty).environmentObject(navModel)
                        case .chooseQuizLevel(let words, let category):
                            СhooseQuizLevelView(items: words, category: category).environmentObject(navModel)
                        case .analysis(let quizQuestions):
                            QuizReviewView(history: quizQuestions).environmentObject(navModel)
                        case .myProgress(let category):
                            MyProgressView(category: category).environmentObject(navModel)
                        case .aboutApp:
                            AboutAppView().environmentObject(navModel)
                        case .writing(let words, let category):
                            WritingView(items: words, category: category).environmentObject(navModel)
                        case .onboardingProfile:
                            OnboardingProfileView().environmentObject(navModel)
                        case .globalRanking(let gameType, let level, let quizDifficulty):
                            GlobalRankingView(gameType: gameType, level: Level(rawValue: level) ?? .a1, quizDifficulty: quizDifficulty)
                        case .widgetWordSelection:
                            WidgetWordSelectionView(modelContext: modelContext).environmentObject(navModel)
                        case .prepositionsList:
                            PrepositionsListView().environmentObject(navModel)
                        case .prepositionDetail(let id, let path, let lemma):
                            PrepositionDetailView(
                                prepositionId: id,
                                detailPath: path,
                                lemma: lemma,
                                articleSource: .menu
                            )
                        }
                    }
            }
            if showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showSplash = false
                        }
                    }
                }
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                WidgetAnalyticsService.sync()
            }
        }
    }
}


