import SwiftUI
import Combine

struct WritingView: View {
    @StateObject var viewModel: WritingViewModel
    @EnvironmentObject private var nav: NavigationViewModel
    @FocusState private var isFieldFocused: Bool
    @State private var showExitAlert = false
    @State private var showRules = false
    let textLimit = 30
    
    init(items: [WordItem], category: Category) {
        _viewModel = StateObject(wrappedValue: WritingViewModel(items: items, currentCategory: category))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                title: L10n.Writing.title + " \(viewModel.currentIndex + 1)/\(viewModel.numberOfQuestions)",
                showExitAlert: $showExitAlert,
                onInfoAction: { showRules = true }
            )
            
            VStack(spacing: 16) {
                Text(viewModel.currentWord.translationWordWithPrep(for: viewModel.currentLanguage))
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .id(viewModel.currentIndex)
                
                Text(viewModel.currentWord.caseType.uppercased())
                    .font(.system(size: 12, weight: .heavy))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            }
            .padding(.top, 40)
            
            Spacer()
            
            VStack(spacing: 12) {
                
                TextField(L10n.Writing.placeholder, text: $viewModel.userInput)
                    .focused($isFieldFocused)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(borderColor, lineWidth: 3)
                            .background(borderColor.opacity(0.05))
                    )
                    .padding(.horizontal, 24)
                    .disabled(viewModel.currentResult != nil)
                        .onChange(of: viewModel.userInput) { oldValue, newValue in
                            if newValue.count > textLimit {
                                viewModel.userInput = String(newValue.dropLast())
                            }
                        }
                    .onSubmit {
                        if viewModel.currentResult == nil {
                            viewModel.checkAnswer()
                        }
                    }
                
                if viewModel.showHint, let result = viewModel.currentResult {
                    WritingHintCard(
                        result: result,
                        title: viewModel.hintTitle,
                        attributedMessage: viewModel.getFormattedHint(),
                        otherVariants: viewModel.otherVariants,
                        alsoText: L10n.Writing.Hint.also,
                        correctVariantsText: L10n.Writing.Hint.correctVariants
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .opacity
                    ))
                } else {
                    Text("\(viewModel.userInput.count)/\(textLimit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            ZStack {
                if viewModel.currentIndex + 1 == viewModel.numberOfQuestions && viewModel.currentResult != nil {
                    AppButton(
                        title: L10n.Quiz.Button.finish, minHeight: 56, background: .blue
                    ) {
                        viewModel.saveResult()
                        let context = QuizResultContext(
                            correctAnswers: viewModel.correctAnswers,
                            resultsHistory: viewModel.resultsHistory,
                            gameType: .writing,
                            numberOfQuestions: viewModel.numberOfQuestions
                        )
                        nav.goTo(.result(context))
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    AppButton(title: viewModel.currentResult != nil ? L10n.Writing.Button.next : L10n.Writing.Button.check, minHeight: 56, background: .yellow) {
                        withAnimation {
                            if viewModel.currentResult != nil {
                                viewModel.nextWord()
                            } else {
                                viewModel.checkAnswer()
                            }
 
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
            .disabled(viewModel.userInput.isEmpty && viewModel.currentResult == nil)
        }
        .background(AppTheme.mainGradient.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            isFieldFocused = true
            viewModel.restartGame()
        }
        .sheet(isPresented: $showRules) {
            LearningRulesView(context: .writing)
        }
        .showAlert(
            title: L10n.Alert.FinishWriting.title,
            isPresented: $showExitAlert,
            onExit: {
                viewModel.logAbandonedIfNeeded()
                nav.backToRoot()
            }
        )
    }
    
    // MARK: - Computed Colors (теперь на базе Enum)
    
    private var borderColor: Color {
        guard let result = viewModel.currentResult else { return .blue.opacity(0.3) }
        switch result {
        case .perfect: return .green
        case .missingUmlaut, .extraUmlaut: return .orange
        case .wrong: return .red
        }
    }
}

extension Binding where Value == String {
    
    func maxLength(_ length: Int) -> Binding<String> {
        Binding(
            get: { wrappedValue },
            set: { newValue in
                if newValue.count <= length {
                    wrappedValue = newValue
                }
            }
        )
    }
}
