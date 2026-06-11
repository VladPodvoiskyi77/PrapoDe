import SwiftUI
import Foundation

struct SpeedQuizView: View {
    @EnvironmentObject private var nav: NavigationViewModel
    @StateObject private var viewModel: SpeedQuizViewModel
    @State private var showExitAlert = false
    @State private var showOnboarding = false
    
    init(items: [WordItem], category: String, difficulty: QuizDifficulty) {
        _viewModel = StateObject(wrappedValue: SpeedQuizViewModel(items: items, categoryName: category, difficulty: difficulty))
    }
    
    var body: some View {
        ZStack {
            AppTheme.mainGradient
                .ignoresSafeArea()
            
            viewModel.feedbackColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.25), value: viewModel.feedbackColor)
            
            VStack(spacing: 24) {
                HeaderView(
                    title: L10n.SpeedQuiz.title + " \(viewModel.currentIndex + 1)/\(viewModel.difficulty.questionCount)",
                    showExitAlert: $showExitAlert
                )
                
                SpeedQuizHeader(
                    timeRemaining: viewModel.timeRemaining,
                    totalTime: viewModel.totalTime,
                    score: viewModel.correctAnswers
                )
                .padding(.horizontal)
                
                Spacer()
                
                if let item = viewModel.currentWord {
                    VStack(spacing: 24) {
                        QuestionCard(item: item, isAnswered: false)
                            .id("q_\(item.id)")
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        
                        SpeedAnswerGrid(options: viewModel.options) { selectedOption in
                            viewModel.selectAnswer(selectedOption)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                Spacer()
            }
            .blur(radius: (viewModel.isCountingDown || showExitAlert) ? 15 : 0)
            .disabled(showExitAlert)
            
            if viewModel.isCountingDown {
                Color.black.opacity(0.4).ignoresSafeArea()
                
                Text(viewModel.countdownValue > 0 ? "\(viewModel.countdownValue)" : L10n.SpeedQuiz.Countdown.go)
                    .font(.system(size: 80, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .transition(.scale.combined(with: .opacity))
                    .id(viewModel.countdownValue)
            }
        }
        .navigationBarBackButtonHidden(true)
        
        .onAppear { viewModel.startFullSequence() }
        
        .onChange(of: showExitAlert) { _, isPresented in
            if isPresented {
                viewModel.pauseGame()
            } else {
                if !viewModel.isCountingDown {
                    viewModel.resumeGame()
                }
            }
        }
        
        .showAlert(
            title: L10n.Alert.FinishTest.title,
            description: L10n.Alert.FinishTest.description,
            isPresented: $showExitAlert,
            onExit: {
                viewModel.logAbandonedIfNeeded()
                viewModel.stopGame()
                nav.backToRoot()
            }
        )
        
        .onChange(of: viewModel.isGameFinished) { _, finished in
            if finished {
                if UserProfileManager.shared.isProfileSetupComplete {
                    proceedToResults()
                } else {
                    showOnboarding = true
                }
            }
        }
        
        .onDisappear {
            viewModel.stopGame()
            print("👋 SpeedQuizView исчез")
        }
        
        .fullScreenCover(isPresented: $showOnboarding, onDismiss: {
            proceedToResults()
        }) {
            OnboardingProfileView().interactiveDismissDisabled()
        }
    }
    
    private func proceedToResults() {
        viewModel.saveResult()
        
        let context = QuizResultContext(
            correctAnswers: viewModel.correctAnswers,
            resultsHistory: viewModel.resultsHistory,
            quizDifficulty: viewModel.difficulty,
            gameType: .sprint,
            numberOfQuestions: viewModel.difficulty.questionCount
        )
        
        nav.goTo(.result(context))
    }
}
