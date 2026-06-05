import FirebaseFirestore
import FirebaseAuth

// Протокол для записи (используем в игровых экранах)
protocol LeaderboardWriting {
    func uploadResult(_ result: QuizResult, quizDifficulty: QuizDifficulty, profile: UserProfileManager)
}

// Протокол для чтения (используем в экране рейтинга)
protocol LeaderboardReading {
    func fetchTopScores(
        gameType: GameType,
        quizDifficulty: QuizDifficulty,
        level: String,
        countryCode: String?
    ) async throws -> [GlobalRankingEntry]
}

final class FirebaseLeaderboardService: LeaderboardWriting, LeaderboardReading {
    private let db = Firestore.firestore()
    
    // 1. Единое имя коллекции для всех результатов
    private let mainCollection = "global_leaderboard"
    private let isTestingMode = false
    
    // MARK: - Writing (Сохранение лучшего результата)
    func uploadResult(_ result: QuizResult, quizDifficulty: QuizDifficulty, profile: UserProfileManager) {
        // 1. Проверка: настроен ли профиль
        guard profile.isProfileSetupComplete else {
            print("ℹ️ Профиль не завершен, пропуск загрузки.")
            return
        }
        
        // 2. БЕРЕМ UID ИЗ НАШЕГО МЕНЕДЖЕРА ✅
        // Теперь мы не используем ?? "unknown_user", а делаем guard.
        // Если ID еще нет (что маловероятно после целого квиза), мы просто выходим.
        guard let realUid = profile.currentUid else {
            print("❌ Ошибка: UID не найден в UserProfileManager. Запись невозможна.")
            return
        }
        
        // Определяем userId (тестовый или реальный)
        let userId = isTestingMode ? "test_\(UUID().uuidString.prefix(8))" : realUid
        
        // 3. Уникальный ID документа (оставляем твою логику)
        let documentId = "\(userId)_\(result.gameType.rawValue)_\(quizDifficulty.questionCount)_\(result.levelRaw)"
        let docRef = db.collection(mainCollection).document(documentId)
        
        Task {
            do {
                let snapshot = try await docRef.getDocument()
                var shouldUpload = true
                
                if snapshot.exists, let data = snapshot.data() {
                    let oldScore = data["score"] as? Int ?? 0
                    let oldTime = data["timeElapsed"] as? Double ?? Double.infinity
                    
                    let isBetterScore = result.score > oldScore
                    let isSameScoreButFaster = (result.score == oldScore && (result.timeElapsed ?? 0.0) < oldTime)
                    
                    shouldUpload = isBetterScore || isSameScoreButFaster
                }
                
                if shouldUpload {
                    let recordData: [String: Any] = [
                        "userId": userId,
                        "userName": profile.userNickname,
                        "countryCode": profile.userCountryCode.uppercased(),
                        "gameType": result.gameType.rawValue,
                        "level": result.levelRaw,
                        "category": result.category,
                        "score": result.score,
                        "total": result.total,
                        "timeElapsed": result.timeElapsed ?? 0.0,
                        "timestamp": FieldValue.serverTimestamp()
                    ]
                    
                    try await docRef.setData(recordData, merge: true)
                    print("✅ Рекорд обновлен: \(documentId)")
                } else {
                    print("ℹ️ Результат (\(result.score)) не лучше рекорда (\(snapshot.data()?["score"] ?? 0)).")
                }
            } catch {
                print("❌ Ошибка Firestore: \(error.localizedDescription)")
                CrashReporter.record(error, context: [
                    "operation": "uploadResult",
                    "documentId": documentId,
                    "gameType": result.gameType.rawValue
                ])
            }
        }
    }
    
    // MARK: - Reading (Запрос из единой коллекции через фильтры)
    func fetchTopScores(
        gameType: GameType,
        quizDifficulty: QuizDifficulty,
        level: String,
        countryCode: String? = nil
    ) async throws -> [GlobalRankingEntry] {
        
        let scopeLabel = countryCode.map { "country \($0.uppercased())" } ?? "worldwide"
        print("🔍 Запрос рейтинга: \(gameType.rawValue), \(quizDifficulty.questionCount), \(level), \(scopeLabel)")
        
        let baseQuery = db.collection(mainCollection)
            .whereField("gameType", isEqualTo: gameType.rawValue)
            .whereField("total", isEqualTo: quizDifficulty.questionCount)
            .whereField("level", isEqualTo: level)
        
        if let countryCode, !countryCode.isEmpty {
            // Фильтр по стране на клиенте: не требует отдельного composite index в Firestore
            let snapshot = try await baseQuery.getDocuments()
            let normalizedCode = countryCode.uppercased()
            
            let entries = snapshot.documents.compactMap { document -> GlobalRankingEntry? in
                try? document.data(as: GlobalRankingEntry.self)
            }
            
            let countryEntries = entries
                .filter { $0.countryCode.uppercased() == normalizedCode }
                .sorted { lhs, rhs in
                    if lhs.score != rhs.score { return lhs.score > rhs.score }
                    return lhs.timeElapsed < rhs.timeElapsed
                }
            
            print("🌍 Рейтинг по стране \(normalizedCode): \(countryEntries.count) из \(entries.count)")
            return Array(countryEntries.prefix(AppConfig.Constants.topScores))
        }
        
        let snapshot = try await baseQuery
            .order(by: "score", descending: true)
            .order(by: "timeElapsed", descending: false)
            .limit(to: AppConfig.Constants.topScores)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: GlobalRankingEntry.self)
        }
    }
}

