import FirebaseStorage
import FirebaseCore

final class FirebaseService: RemoteDataFetching {
    
    // Безопасно проверяем, инициализирован ли Firebase
    private var storage: Storage {
        // Проверяем: словарь не nil И он не пустой
        guard let apps = FirebaseApp.allApps, !apps.isEmpty else {
            // Если мы попали сюда — значит FirebaseApp.configure() еще не вызвался
            fatalError("❌ Попытка доступа к Firebase Storage до вызова FirebaseApp.configure()")
        }
        return Storage.storage()
    }
    
    func download(path: String) async throws -> Data {
        let ref = storage.reference().child(path)
        return try await ref.data(maxSize: 10 * 1024 * 1024)
    }
}
