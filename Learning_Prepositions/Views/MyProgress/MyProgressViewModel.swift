import SwiftUI

@MainActor
class MyProgressViewModel: BaseDataViewModel {
    
    // MARK: - Данные
    @Published var words: [WordItem] = []
    @Published var searchText = ""
    @Published var showStatusAlert = false
    @Published var statusAlertTitle = ""
    @Published var statusAlertDescription = ""
    
    // MARK: - Настройки
    
    @Published var showFilterCarousel = false
    @Published var selectedPreposition: String? = nil // Если nil, то показываем все
    @Published var activePreposition: String? = nil   // реально применённый фильтр
    
    // Служебные
    private let category: Category
    
    // MARK: - Init
    init(category: Category) {
        self.category = category
        super.init()
        
        Task {
            await loadData()
        }
    }
    
    // MARK: - Логика фильтрации
    
    // 1. Собираем все уникальные предлоги из текущего списка слов
    var availablePrepositions: [String] {
        let allPreps = words.map { $0.preposition }
        // Удаляем дубликаты через Set и сортируем по алфавиту
        return Array(Set(allPreps)).sorted()
    }
    
    var filteredWords: [WordItem] {
        let searchResult: [WordItem]
        
        if searchText.isEmpty {
            searchResult = words
        } else {
            searchResult = words.filter {
                $0.basePreposition.localizedCaseInsensitiveContains(searchText) ||
                $0.translation(for: currentLanguage)
                    .localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let prep = activePreposition {
            return searchResult.filter { $0.preposition == prep }
        } else {
            return searchResult
        }
    }
    
    func closeAndResetFilter() {
        withAnimation(.spring()) {
            showFilterCarousel = false
            selectedPreposition = nil
            activePreposition = nil
        }
    }
    
    // MARK: - Загрузка данных
    func loadData() async {
        // Вызываем метод загрузки из BaseDataViewModel
        guard let loaded = await performLoad(category: category) else {
            return
        }
        
        // Обновляем UI (автоматически на Main Thread из-за @MainActor)
        self.words = loaded
    }
    
    func refreshData() {
            Task {
                // Вызываем логику из базовой модели
                let (newItems, result) = await performUpdate(category: category)
                
                // Логика выбора текста и состояния происходит ЗДЕСЬ ✅
                switch result {
                case .updated:
                    if let items = newItems {
                        self.words = items // Обновляем список в UI
                        // Настраиваем успех через L10n
                        self.statusAlertTitle = L10n.MyProgress.Update.Alert.Success.title
                        self.statusAlertDescription = L10n.MyProgress.Update.Alert.Success.description
                        self.showStatusAlert = true
                    }
                    
                case .noChanges:
                    // Настраиваем "нет изменений" через L10n
                    self.statusAlertTitle = L10n.MyProgress.Update.Alert.NoChanges.title
                    self.statusAlertDescription = L10n.MyProgress.Update.Alert.NoChanges.description
                    self.showStatusAlert = true
                    
                case .error(let message):
                    // Ошибка уже обрабатывается через showError в BaseDataViewModel
                    // (если ты так реализовал performUpdate),
                    // поэтому здесь можно просто вывести в консоль для дебага
                    print("❌ Update error: \(message)")
                }
            }
        }
    
    // MARK: - Статистика
    
    var totalWords: Int {
        words.count
    }
    
    var learnedWords: Int {
        words.filter { $0.isLearned }.count
    }
    
    var progressValue: Double {
        guard totalWords > 0 else { return 0 }
        return Double(learnedWords) / Double(totalWords)
    }
}
