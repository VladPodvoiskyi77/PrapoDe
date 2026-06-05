import Foundation

protocol LocalDataCaching {
    func load(key: String) -> Data?
    func save(data: Data, key: String)
    func remove(key: String)
}
