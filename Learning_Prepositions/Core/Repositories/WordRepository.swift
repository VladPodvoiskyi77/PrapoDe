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
        let storedVersion = AppConfig.appGroupStore.integer(forKey: WidgetCatalog.versionKey)
        let needsCatalogRebuild = storedVersion < WidgetCatalog.currentVersion
        
        if !force && !needsCatalogRebuild && existingCount > 0 {
            print("✅ SwiftData уже заполнена (\(existingCount) эл.)")
            return
        }
        
        let path = AppConfig.Constants.widgetJsonPath
        // On catalog rebuild always prefer a fresh Firebase download (stale App Group cache
        // was a source of wrong verb counts after schema changes).
        var rawData: Data?
        let shouldPreferRemote = force || needsCatalogRebuild
        if shouldPreferRemote, network.isConnected {
            do {
                print("☁️ Качаем свежий список для виджета из Firebase...")
                let remoteData = try await remote.download(path: path)
                local.save(data: remoteData, key: path)
                rawData = remoteData
            } catch {
                print("⚠️ Remote widget download failed, trying cache: \(error)")
                rawData = local.load(key: path)
            }
        } else if let cachedData = local.load(key: path) {
            rawData = cachedData
            print("📦 Берем данные виджета из локального кэша.")
        } else if network.isConnected {
            print("☁️ Качаем свежий список для виджета из Firebase...")
            let remoteData = try await remote.download(path: path)
            local.save(data: remoteData, key: path)
            rawData = remoteData
        }
        
        guard let data = rawData else { return }
        
        do {
            let verbs = try JSONDecoder().decode([VerbItem].self, from: data)
            
            // Firebase has rare exact duplicate rows; keep first occurrence only.
            var seenIds = Set<String>()
            let deduped = verbs.filter { item in
                let id = VerbEntity.makeCatalogId(
                    base: item.base,
                    preposition: item.preposition,
                    levelRaw: item.level.rawValue
                )
                return seenIds.insert(id).inserted
            }
            
            let previous = (try? context.fetch(descriptor)) ?? []
            var previousVisibility: [String: Bool] = [:]
            for entity in previous {
                previousVisibility[entity.catalogId] = entity.isShow
            }
            
            try context.delete(model: VerbEntity.self)
            
            for item in deduped {
                let entity = VerbEntity(from: item)
                entity.isShow = previousVisibility[entity.catalogId] ?? true
                context.insert(entity)
            }
            
            try context.save()
            AppConfig.appGroupStore.set(WidgetCatalog.currentVersion, forKey: WidgetCatalog.versionKey)
            let a1Count = deduped.filter { $0.level == .a1 }.count
            print("💾 База виджета перезаписана: \(deduped.count) эл. (из \(verbs.count)), A1=\(a1Count)")
            
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

    /// Manual update from the widget word-selection screen (same UX as My Progress).
    @MainActor
    func forceUpdateWidgetData(context: ModelContext) async throws -> UpdateResult {
        guard network.isConnected else { throw AppError.noInternet }

        let path = AppConfig.Constants.widgetJsonPath
        let remoteData = try await remote.download(path: path)
        let remoteItems: [VerbItem] = try decode(data: remoteData)
        let deduped = Self.dedupeWidgetItems(remoteItems)

        let descriptor = FetchDescriptor<VerbEntity>()
        let existing = (try? context.fetch(descriptor)) ?? []

        if Self.sameWidgetCatalogContent(existing: existing, remote: deduped) {
            print("✨ Виджет-каталог без изменений.")
            return .noChanges
        }

        try applyWidgetCatalog(deduped, context: context, existing: existing)
        AppConfig.appGroupStore.set(WidgetCatalog.currentVersion, forKey: WidgetCatalog.versionKey)
        local.remove(key: path)
        WidgetCenter.shared.reloadAllTimelines()
        print("✅ Виджет-каталог обновлён: \(deduped.count) эл.")
        return .updated
    }

    private static func dedupeWidgetItems(_ verbs: [VerbItem]) -> [VerbItem] {
        var seenIds = Set<String>()
        return verbs.filter { item in
            let id = VerbEntity.makeCatalogId(
                base: item.base,
                preposition: item.preposition,
                levelRaw: item.level.rawValue
            )
            return seenIds.insert(id).inserted
        }
    }

    private static func sameWidgetCatalogContent(existing: [VerbEntity], remote: [VerbItem]) -> Bool {
        func remoteKey(_ item: VerbItem) -> String {
            let id = VerbEntity.makeCatalogId(
                base: item.base,
                preposition: item.preposition,
                levelRaw: item.level.rawValue
            )
            return [
                id,
                item.translationRu,
                item.translationUa,
                item.translationEn,
                item.exampleSentence,
                item.caseType.rawValue,
            ].joined(separator: "||")
        }
        func localKey(_ entity: VerbEntity) -> String {
            [
                entity.catalogId,
                entity.translationRu,
                entity.translationUa,
                entity.translationEn,
                entity.exampleSentence,
                entity.caseTypeRaw,
            ].joined(separator: "||")
        }
        return Set(existing.map(localKey)) == Set(remote.map(remoteKey))
    }

    @MainActor
    private func applyWidgetCatalog(
        _ items: [VerbItem],
        context: ModelContext,
        existing: [VerbEntity]
    ) throws {
        var previousVisibility: [String: Bool] = [:]
        for entity in existing {
            previousVisibility[entity.catalogId] = entity.isShow
        }
        try context.delete(model: VerbEntity.self)
        for item in items {
            let entity = VerbEntity(from: item)
            entity.isShow = previousVisibility[entity.catalogId] ?? true
            context.insert(entity)
        }
        try context.save()
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
