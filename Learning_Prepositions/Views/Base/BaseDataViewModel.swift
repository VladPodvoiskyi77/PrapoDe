import SwiftUI
import WidgetKit
import SwiftData

@MainActor
class BaseDataViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var showError = false
    @Published var appError: AppError?
    
    private static let sharedDefaults = AppConfig.appGroupStore
    
    internal let repository = WordRepository()
    private let validator: WordValidating = WordValidator()
    
    // MARK: - Данные из App Group (Только чтение)
    
    @AppStorage("selectedLanguage", store: BaseDataViewModel.sharedDefaults)
    private(set) var selectedLanguageRaw: String = Language.ru.rawValue
    
    // Уровень получаем напрямую из UserDefaults App Group
    var currentLevelRaw: String {
        BaseDataViewModel.sharedDefaults.string(forKey: "selectedLevel") ?? Level.a1.rawValue
    }
    
    // Удобный хелпер для получения Enum языка
    var currentLanguage: Language {
        Language(rawValue: selectedLanguageRaw) ?? .ru
    }
    
    func performLoad(category: Category) async -> [WordItem]? {
        print("📥 Загрузка: \(category.rawValue), Уровень: \(currentLevelRaw)")
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let items: [WordItem] = try await repository.fetchItems(
                level: currentLevelRaw,
                category: category.fileName
            )
            return validator.validate(items)
            
        } catch let error as AppError {
            CrashReporter.recordAppError(error, context: [
                "operation": "performLoad",
                "category": category.fileName
            ])
            self.appError = error
            self.showError = true
            return nil
        } catch {
            CrashReporter.record(error, context: [
                "operation": "performLoad",
                "category": category.fileName
            ])
            self.appError = .unknown
            self.showError = true
            return nil
        }
    }
    
    func performUpdate(category: Category) async -> (items: [WordItem]?, result: UpdateResult) {
        print("🔄 Запрос на обновление: \(category.rawValue), Уровень: \(currentLevelRaw)")
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // 1. Вызываем твой метод из репозитория
            let updateResult = try await repository.forceUpdateCategory(
                level: currentLevelRaw,
                category: category.fileName
            )
            
            // 2. Если данные реально обновились (.updated)
            if case .updated = updateResult {
                // Загружаем уже обновленный и склеенный массив из локального хранилища
                // (fetchItems у тебя умеет брать из кэша)
                let updatedItems: [WordItem] = try await repository.fetchItems(
                    level: currentLevelRaw,
                    category: category.fileName
                )
                
                // Валидируем и возвращаем вместе со статусом
                let validated = validator.validate(updatedItems)
                return (validated, .updated)
            }
            
            // 3. Если изменений нет (.noChanges), возвращаем nil в массиве
            return (nil, updateResult)
            
        } catch let error as AppError {
            CrashReporter.recordAppError(error, context: [
                "operation": "performUpdate",
                "category": category.fileName
            ])
            self.appError = error
            self.showError = true
            return (nil, .error(error.localizedDescription))
        } catch {
            CrashReporter.record(error, context: [
                "operation": "performUpdate",
                "category": category.fileName
            ])
            self.appError = .unknown
            self.showError = true
            return (nil, .error("Unexpected error"))
        }
    }
    
    func performStartupCheck(context: ModelContext) async {
        print("🚀 Проверка данных виджета при старте...")
        
        do {
            // Вызываем без параметров - сработает проверка "если есть, то не качай"
            try await repository.syncWidgetData(context: context, force: false)
        } catch {
            print("⚠️ Ошибка фоновой проверки: \(error)")
            CrashReporter.record(error, context: "performStartupCheck")
        }
    }
}
