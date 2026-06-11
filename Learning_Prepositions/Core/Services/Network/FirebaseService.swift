import FirebaseStorage
import FirebaseCore

final class FirebaseService: RemoteDataFetching {
    
    private var storage: Storage {
        guard let apps = FirebaseApp.allApps, !apps.isEmpty else {
            fatalError("❌ Попытка доступа к Firebase Storage до вызова FirebaseApp.configure()")
        }
        return Storage.storage()
    }
    
    func download(path: String) async throws -> Data {
        let ref = storage.reference().child(path)
        return try await ref.data(maxSize: 10 * 1024 * 1024)
    }
}
