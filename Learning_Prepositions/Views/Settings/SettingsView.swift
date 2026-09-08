import SwiftUI
import WidgetKit

struct SettingsView: View {
    @EnvironmentObject private var nav: NavigationViewModel
    @StateObject private var viewModel = SettingsViewModel()
    
    @AppStorage("questionCount", store: AppConfig.appGroupStore) private var questionCount = 10
    
    @AppStorage(AppConfig.Keys.selectedLanguage, store: AppConfig.appGroupStore)
    private var selectedLanguageRawValue = Language.en.rawValue
    
    @AppStorage(AppConfig.Keys.selectedLevel, store: AppConfig.appGroupStore)
    private var selectedLevelRawValue = Level.a1.rawValue
    
    @State private var showResetAlert = false
    
    var body: some View {
        ZStack {
            AppTheme.mainGradient
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    header
                    
                    LanguageSection(
                        selectedLanguageRawValue: $selectedLanguageRawValue,
                        selectedLevelRawValue: $selectedLevelRawValue)
                    
                    QuizSettingsSection(
                        questionCount: $questionCount
                    )
                    
                    WidgetSection {
                        nav.goTo(.widgetWordSelection)
                    }
                    
                    ResultSection(
                        onGoToLeaderboard: { nav.goTo(.leaderboard(ResultContext())) },
                        onGoToSprintRanking: { nav.goTo(.globalRanking(.sprint, selectedLevelRawValue, .easy)) },
                    )
                    
                    GeneralSettingsSection(
                        onSendFeedback: { sendFeedbackEmail() },
                        onGoToAboutApp: { nav.goTo(.aboutApp) },
                        onResetProgress: { showResetAlert = true }
                    )
                    
                    appVersionFooter
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            let normalized = AppConfig.QuizSettings.normalizeQuestionCount(questionCount)
            if normalized != questionCount {
                questionCount = normalized
            }
            AnalyticsManager.shared.logScreenView("Settings")
            AnalyticsManager.shared.setUserLevel(selectedLevelRawValue)
        }
        .onChange(of: selectedLevelRawValue) { oldValue, newValue in
            print("🔄 Уровень изменен")
            AnalyticsManager.shared.setUserLevel(newValue)
            refreshWidget()
        }
        .onChange(of: selectedLanguageRawValue) { oldValue, newValue in
            print("🌐 Язык изменен")
            refreshWidget()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .navigationBarBackButtonHidden(false)
        
        .showAlert(
            title: L10n.Alert.ResetResults.title,
            isPresented: $showResetAlert,
            onExit: { viewModel.resetResults() }
        )
    }
    
    // MARK: - Subviews
    
    private var header: some View {
        Text(L10n.Settings.title)
            .font(.system(size: 40, weight: .bold, design: .rounded))
            .foregroundStyle(.primary) // Адаптивный цвет (черный/белый)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 20)
            }
    
    private var appVersionFooter: some View {
        Text(viewModel.appVersion)
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.top, 10)
    }
    
    private func refreshWidget() {
        print("♻️ Обновление виджета...")
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // MARK: - Logic
    
    private func sendFeedbackEmail() {
        if let url = viewModel.getSupportEmailURL() {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    SettingsView()
}


