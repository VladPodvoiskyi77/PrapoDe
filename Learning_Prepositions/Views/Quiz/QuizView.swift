import SwiftUI

struct QuizView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var nav: NavigationViewModel
    @StateObject private var viewModel: QuizViewModel
    @State private var showExitAlert = false
    @State private var flip = false
    
    init(items: [WordItem], filteredItem: [WordItem], categoryName: String) {
        _viewModel = StateObject(wrappedValue: QuizViewModel(fullWordItems: items, filteredItem: filteredItem, categoryName: categoryName))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            HeaderView(
                title: L10n.Quiz.title + " \(viewModel.currentIndex + 1)/\(viewModel.totalQuestions)",
                showExitAlert: $showExitAlert
            )
            .padding(.top, 16)
            
            // MARK: - Верхний блок (Слово + Падеж)
            VStack(spacing: 12) {
                HStack(alignment: .center, spacing: 10) {
                    Text(viewModel.currentWord.formattedTranslation(for: viewModel.currentLanguage))
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .layoutPriority(1)
                    
                    Button {
                        Speaker.shared.speak(viewModel.currentWord.basePreposition)
                    } label: {
                        Image(systemName: "speaker.wave.2.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
                .opacity(viewModel.isAnswered ? 1 : 0)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isAnswered)
                
                ZStack {
                    Color.clear
                        .frame(width: 140, height: 44)
                    
                    if viewModel.isAnswered {
                        Text(viewModel.currentWord.caseType)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(caseColor)
                            .frame(width: 140, height: 44)
                            .background(
                                Capsule()
                                    .fill(caseColor.opacity(0.15))
                            )
                            .overlay(
                                Capsule().strokeBorder(caseColor.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: caseColor.opacity(0.2), radius: 8, y: 4)
                            .rotation3DEffect(
                                .degrees(flip ? 0 : 180),
                                axis: (x: 0, y: 1, z: 0)
                            )
                            .onAppear {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                    flip = true
                                }
                            }
                            .onDisappear { flip = false }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
            
            // MARK: - Вопрос (Карточка)
            
            ZStack {
                ForEach(Array(viewModel.wordItems.enumerated()), id: \.element.id) { index, item in
                    if index == viewModel.currentIndex {
                        QuestionBlock(viewModel: viewModel, item: item)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                }
            }
            .animation(.easeInOut(duration: 0.35), value: viewModel.currentIndex)
            .frame(height: 360)
            .padding(.horizontal, 16)
            
            // MARK: - Пример и перевод (Нижний блок)
            VStack(spacing: 8) {
                Text(viewModel.wordItems[viewModel.currentIndex].translation(for: viewModel.currentLanguage))
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 8)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(height: 60)
            .opacity(viewModel.isAnswered ? 1 : 0)
            .animation(.easeInOut, value: viewModel.isAnswered)
            
            Spacer()
            
            // MARK: - Кнопка действия
            
            ZStack {
                if viewModel.isAnswered {
                    if viewModel.currentIndex + 1 == viewModel.totalQuestions {
                        AppButton(
                            title: L10n.Quiz.Button.finish, minHeight: 56, background: .blue
                        ) {
                            viewModel.saveResult()
                            let context = QuizResultContext(correctAnswers: viewModel.correctAnswers,
                                                            resultsHistory: viewModel.resultsHistory,
                                                            gameType: .quiz,
                                                            numberOfQuestions: viewModel.totalQuestions)
                            nav.goTo(.result(context))
                        }
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        AppButton(title: L10n.Quiz.Button.next, minHeight: 56, background: .yellow) {
                            withAnimation {
                                viewModel.nextQuestion()
                            }
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                } else {
                    Color.clear.frame(height: 56)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .background(AppTheme.mainGradient.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .showAlert(title: L10n.Alert.FinishTest.title,
                   description: L10n.Alert.FinishTest.description,
                   isPresented: $showExitAlert,
                   onExit: {
            viewModel.logAbandonedIfNeeded()
            dismiss()
        })
        .onAppear {
            viewModel.refreshData()
        }
    }
    
    private var caseColor: Color {
        viewModel.currentWord.caseColor
    }
}
