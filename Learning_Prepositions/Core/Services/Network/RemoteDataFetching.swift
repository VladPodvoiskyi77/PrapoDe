import Foundation

protocol RemoteDataFetching {
    func download(path: String) async throws -> Data
}

