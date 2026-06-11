import Foundation
import SwiftData
import WidgetKit

final class WordRepository {
    private let remote: RemoteDataFetching
    private let local: LocalDataCaching
    private let network: NetworkChecking
    
    init(remote: RemoteDataFetching = FirebaseService(),
         local: LocalDataCaching = FileCacheService(),
         network: NetworkChecking = NetworkMonitor.shared) {
        self.remote = remote
        self.local = local
        self.network = network
    }
    
    func fetchItems<T: Decodable>(level: String, category: String) async throws -> T {
        let path = "data/\(level)/\(category).json"
        
        if let cachedData = local.load(key: path) {
            print("📦 Loaded from Cache: \(path)")
            if let decoded: T = try? decode(data: cachedData) {
                return decoded
            }
        }
        
        guard network.isConnected else {
            // Кэша нет + Интернета нет = Ошибка
            throw AppError.noInternet
        }
        
        print("☁️ Downloading from Remote: \(path)")
        do {
            let remoteData = try await remote.download(path: path)
            
            local.save(data: remoteData, key: path)
            
            return try decode(data: remoteData)
        } catch {
            CrashReporter.record(error, context: [
                "operation": "fetchItems",
                "path": path
            ])
            throw AppError.serverError(error.localizedDescription)
        }
    }
    
    func forceUpdateCategory(level: String, category: String) async throws -> UpdateResult {
        let path = "data/\(level)/\(category).json"
        guard network.isConnected else { throw AppError.noInternet }
        
        let localData = local.load(key: path)
        let localItems: [WordItem] = (localData != nil) ? (try? decode(data: localData!)) ?? [] : []
        
        let remoteData = try await remote.download(path: path)
        let remoteItems: [WordItem] = try decode(data: remoteData)
        
        let mergedItems = mergeProgress(newRemote: remoteItems, oldLocal: localItems)
        
        // Сортируем оба массива перед сравнением, чтобы избежать проблем с порядком ✅
        let sortedMerged = mergedItems.sorted { $0.base < $1.base }
        let sortedLocal = localItems.sorted { $0.base < $1.base }
        
        if sortedMerged == sortedLocal {
            print("✨ Данные идентичны. Обновление не требуется.")
            return .noChanges
        }
        
        // Сохраняем оригинальный mergedItems (порядок из Firebase может быть важен)
        let encoded = try JSONEncoder().encode(mergedItems)
        local.save(data: encoded, key: path)
        
        print("✅ Обнаружены изменения. База обновлена.")
        return .updated
    }
        
    private func mergeProgress(newRemote: [WordItem], oldLocal: [WordItem]) -> [WordItem] {
        // 1. Создаем словарь безопасно.
        let progressMap = Dictionary(oldLocal.map {
            ("\($0.base)_\($0.preposition)", $0)
        }, uniquingKeysWith: { (first, second) in
            // Дидактическая логика: если есть дубликат, берем тот, что лучше выучен
            return first.learningScore >= second.learningScore ? first : second
        })
        
        return newRemote.map { newItem in
            let key = "\(newItem.base)_\(newItem.preposition)"
            
            if let localEntry = progressMap[key] {
                var updated = newItem
                // Сохраняем ID для корректной работы Equatable
                updated.id = localEntry.id
                
                updated.learningScore = localEntry.learningScore
                updated.isLearned = localEntry.isLearned
                updated.lastReviewDate = localEntry.lastReviewDate
                return updated
            }
            return newItem
        }
    }
    
    // MARK: - Widget Sync
    @MainActor
    func syncWidgetData(context: ModelContext, force: Bool = false) async throws {
        
        let descriptor = FetchDescriptor<VerbEntity>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        
        if !force && existingCount > 0 {
            print("✅ SwiftData уже заполнена (\(existingCount) эл.)")
            return
        }
        
        // 2. ИСТОЧНИК: Берем JSON (Кэш или Firebase)
        let path = AppConfig.Constants.widgetJsonPath
        var rawData: Data?
        if let cachedData = local.load(key: path) {
            rawData = cachedData
            print("📦 Берем данные из локального кэша.")
        } else {
            guard network.isConnected else { return }
            print("☁️ Качаем свежий список для виджета из Firebase...")
            let remoteData = try await remote.download(path: path)
            local.save(data: remoteData, key: path)
            rawData = remoteData
        }
        
        guard let data = rawData else { return }
        
        do {
            let verbs = try JSONDecoder().decode([VerbItem].self, from: data)
            
            // Это гарантирует отсутствие дубликатов без лишних проверок
            try context.delete(model: VerbEntity.self)
            
            for item in verbs {
                context.insert(VerbEntity(from: item))
            }
            
            try context.save()
            print("💾 База виджета полностью перезаписана: \(verbs.count) элементов.")
            
            // Удаляем временный файл кэша, так как теперь всё в базе
            local.remove(key: path)
            
            WidgetCenter.shared.reloadAllTimelines()
            
        } catch {
            print("❌ Ошибка при перезаписи базы: \(error)")
            CrashReporter.record(error, context: [
                "operation": "syncWidgetData",
                "path": path
            ])
        }
    }
    
    func saveItems<T: Encodable>(_ items: T, level: String, category: String) {
        let path = "data/\(level)/\(category).json"
        print("path----->", path)
        
        do {
            let data = try JSONEncoder().encode(items)
            local.save(data: data, key: path)
            print("💾 Progress saved to \(path)")
        } catch {
            print("❌ Failed to encode/save data: \(error)")
            CrashReporter.record(error, context: [
                "operation": "saveItems",
                "path": path
            ])
        }
    }
    
    
    func removeItems(level: String, category: String) {
        let path = "data/\(level)/\(category).json"
        
        local.remove(key: path)
        print("🧹 Cache cleared for path: \(path)")
    }
    
    private func decode<T: Decodable>(data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            CrashReporter.record(error, context: "decodeWordItems")
            throw AppError.decodingError
        }
    }
}
