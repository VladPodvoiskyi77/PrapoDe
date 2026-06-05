import Foundation

final class FileCacheService: LocalDataCaching {
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    private var cacheRoot: URL {
            // 2. Вместо .documentDirectory используем containerURL для App Group
        guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: AppConfig.Constants.appGroupID) else {
                // Фолбэк на случай ошибки, хотя в проде группа должна быть настроена
                return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            }
            return groupURL
        }
    
    // Превращаем "data/level/category.json" в локальный URL
    private func getFileURL(key: String) -> URL {
        // key может приходить как "data/A1/verbs.json"
        // Нам нужно создать вложенные папки
        let fullPath = cacheRoot.appendingPathComponent(key)
        
        // Создаем папку, если её нет (например, caches/data/A1/)
        let folder = fullPath.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: folder.path) {
            try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        
        return fullPath
    }
    
    func load(key: String) -> Data? {
        let url = getFileURL(key: key)
        return try? Data(contentsOf: url)
    }
    
    func save(data: Data, key: String) {
        let url = getFileURL(key: key)
        try? data.write(to: url, options: .atomic)
    }
    
     //TO DO: to manually delete a certain level in the saved files
    func remove(key: String) {
        let url = getFileURL(key: key)
        
        // Проверяем, есть ли файл, чтобы не ловить ошибку
        if fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.removeItem(at: url)
                print("🗑 Файл успешно удален: \(url.lastPathComponent)")
            } catch {
                print("❌ Ошибка удаления файла: \(error)")
            }
        } else {
            print("⚠️ Файл для удаления не найден: \(key)")
        }
    }
}

