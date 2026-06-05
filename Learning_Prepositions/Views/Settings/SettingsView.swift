import SwiftUI
import WidgetKit

struct SettingsView: View {
    @EnvironmentObject private var nav: NavigationViewModel
    //@Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = SettingsViewModel()
    
    // Настройки пользователя
    @AppStorage("questionCount", store: AppConfig.appGroupStore) private var questionCount = 10
    
    @AppStorage(AppConfig.Keys.selectedLanguage, store: AppConfig.appGroupStore)
    private var selectedLanguageRawValue = Language.en.rawValue
    
    @AppStorage(AppConfig.Keys.selectedLevel, store: AppConfig.appGroupStore)
    private var selectedLevelRawValue = Level.a1.rawValue
    
    @State private var showResetAlert = false
    
    var body: some View {
        ZStack {
            // 1. Фон
            AppTheme.mainGradient
                .ignoresSafeArea()
            
            // 2. Контент
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Заголовок
                    header
                    
                    // СЕКЦИЯ 1: язык
                    LanguageSection(
                        selectedLanguageRawValue: $selectedLanguageRawValue,
                        selectedLevelRawValue: $selectedLevelRawValue)
                    
                    // СЕКЦИЯ 2: квиз
                    QuizSettingsSection(
                        questionCount: $questionCount
                    )
                    
                    // СЕКЦИЯ 3: виджет
                    WidgetSection {
                        nav.goTo(.widgetWordSelection)
                    }
                    
                    // СЕКЦИЯ 4: Результаты
                    ResultSection(
                        onGoToLeaderboard: { nav.goTo(.leaderboard(ResultContext())) },
                        onGoToSprintRanking: { nav.goTo(.globalRanking(.sprint, selectedLevelRawValue, .easy)) },
                    )
                    
                    // СЕКЦИЯ 5: Общие
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
            AnalyticsManager.shared.logScreenView("Settings")
            AnalyticsManager.shared.setUserLevel(selectedLevelRawValue)
        }
        // Первый onChange для уровня
        .onChange(of: selectedLevelRawValue) { oldValue, newValue in
            print("🔄 Уровень изменен")
            AnalyticsManager.shared.setUserLevel(newValue)
            refreshWidget()
        }
        // Второй onChange для языка
        .onChange(of: selectedLanguageRawValue) { oldValue, newValue in
            print("🌐 Язык изменен")
            refreshWidget()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .navigationBarBackButtonHidden(false)
        
        // Алерты
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
            .padding(.top, 20) // Чуть уменьшил, так как NavigationBar занимает место сверху
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


