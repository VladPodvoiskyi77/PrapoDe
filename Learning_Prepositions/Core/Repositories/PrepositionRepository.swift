import Foundation

final class PrepositionRepository {
    static let shared = PrepositionRepository()
    
    private let remote: RemoteDataFetching
    private let local: LocalDataCaching
    private let network: NetworkChecking
    
    private static let storageRoot = "Präpositionen"
    private static let explanationsFolder = "Präpositionen/Erklärung"
    private let indexRemotePath = "\(storageRoot)/index.json"
    
    init(
        remote: RemoteDataFetching = FirebaseService(),
        local: LocalDataCaching = FileCacheService(),
        network: NetworkChecking = NetworkMonitor.shared
    ) {
        self.remote = remote
        self.local = local
        self.network = network
    }
    
    func fetchIndex() async throws -> PrepositionIndex {
        try await fetchDecodable(path: indexRemotePath)
    }
    
    func fetchDetail(prepositionId: String, detailPath: String) async throws -> PrepositionDetail {
        try await fetchDecodable(path: normalizedStoragePath(detailPath))
    }
    
    func forceUpdateDetail(path: String) async throws -> UpdateResult {
        let storagePath = normalizedStoragePath(path)
        guard network.isConnected else { throw AppError.noInternet }
        
        let localData = local.load(key: storagePath)
        let remoteData: Data
        do {
            remoteData = try await remote.download(path: storagePath)
        } catch {
            CrashReporter.record(error, context: [
                "operation": "forceUpdatePreposition",
                "path": storagePath
            ])
            throw AppError.contentNotAvailable
        }
        
        guard let _: PrepositionDetail = decode(remoteData) else {
            throw AppError.decodingError
        }
        
        if let localData, localData == remoteData {
            return .noChanges
        }
        
        local.save(data: remoteData, key: storagePath)
        return .updated
    }
    
    // MARK: - Private
    
    private func fetchDecodable<T: Decodable>(path: String) async throws -> T {
        if let cached = local.load(key: path), let decoded: T = decode(cached) {
            return decoded
        }
        
        guard network.isConnected else {
            throw AppError.noInternet
        }
        
        do {
            let data = try await remote.download(path: path)
            guard let decoded: T = decode(data) else {
                throw AppError.decodingError
            }
            local.save(data: data, key: path)
            return decoded
        } catch let error as AppError {
            throw error
        } catch {
            CrashReporter.record(error, context: ["operation": "fetchPreposition", "path": path])
            throw AppError.contentNotAvailable
        }
    }
    
    private func normalizedStoragePath(_ path: String) -> String {
        if path.hasPrefix("\(Self.storageRoot)/") {
            return path
        }
        
        let fileName = (path as NSString).lastPathComponent
        
        if path.hasPrefix("prepositions/") {
            return "\(Self.explanationsFolder)/\(fileName)"
        }
        
        if path.hasPrefix("Erklärung/") || path.hasPrefix("Eklarung/") {
            let relative = path.hasPrefix("Erklärung/")
                ? String(path.dropFirst("Erklärung/".count))
                : String(path.dropFirst("Eklarung/".count))
            return "\(Self.explanationsFolder)/\(relative)"
        }
        
        if !path.contains("/") {
            return "\(Self.explanationsFolder)/\(fileName)"
        }
        
        return path
    }
    
    private func decode<T: Decodable>(_ data: Data) -> T? {
        try? JSONDecoder().decode(T.self, from: data)
    }
}

// MARK: - Lookup (quiz / review → detail article)

@MainActor
final class PrepositionLookup {
    static let shared = PrepositionLookup()

    private let repository: PrepositionRepository
    private var itemsByLemma: [String: PrepositionIndexItem]?

    init(repository: PrepositionRepository = .shared) {
        self.repository = repository
    }

    func indexItem(for lemma: String) async -> PrepositionIndexItem? {
        await ensureCache()
        return itemsByLemma?[lemma.lowercased()]
    }

    private func ensureCache() async {
        guard itemsByLemma == nil else { return }
        guard let index = try? await repository.fetchIndex() else { return }
        itemsByLemma = Dictionary(
            uniqueKeysWithValues: index.items.map { ($0.lemma.lowercased(), $0) }
        )
    }
}
