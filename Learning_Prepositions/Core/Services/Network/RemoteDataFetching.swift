import Foundation

// Отвечает только за загрузку из сети
protocol RemoteDataFetching {
    func download(path: String) async throws -> Data
}

