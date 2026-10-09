import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol LeaderboardWriting {
    func uploadResult(_ result: QuizResult, quizDifficulty: QuizDifficulty, profile: UserProfileManager) async
}

protocol LeaderboardReading {
    func fetchTopScores(
        gameType: GameType,
        quizDifficulty: QuizDifficulty,
        level: String,
        countryCode: String?,
        period: RankingPeriod
    ) async throws -> [GlobalRankingEntry]
}

final class FirebaseLeaderboardService: LeaderboardWriting, LeaderboardReading {
    private let db = Firestore.firestore()
    
    private let mainCollection = "global_leaderboard"
    private let isTestingMode = false
    
    // MARK: - Writing (Сохранение лучшего результата)
    func uploadResult(_ result: QuizResult, quizDifficulty: QuizDifficulty, profile: UserProfileManager) async {
        guard profile.isProfileSetupComplete else {
            print("ℹ️ Профиль не завершен, пропуск загрузки.")
            return
        }

        var resolvedUid = profile.currentUid
        if resolvedUid == nil {
            for _ in 0..<10 {
                try? await Task.sleep(nanoseconds: 300_000_000)
                resolvedUid = profile.currentUid
                if resolvedUid != nil { break }
            }
        }

        guard let realUid = resolvedUid else {
            print("❌ Ошибка: UID не найден в UserProfileManager. Запись невозможна.")
            return
        }

        let userId = isTestingMode ? "test_\(UUID().uuidString.prefix(8))" : realUid
        let documentId = "\(userId)_\(result.gameType.rawValue)_\(quizDifficulty.questionCount)_\(result.levelRaw)"
        let docRef = db.collection(mainCollection).document(documentId)

        do {
            let snapshot = try await docRef.getDocument()
            var shouldUpload = true

            if snapshot.exists, let data = snapshot.data() {
                let oldScore = Self.intValue(data["score"])
                let oldTime = Self.doubleValue(data["timeElapsed"], fallback: Double.infinity)
                let newTime = result.timeElapsed ?? 0.0
                let isBetterScore = result.score > oldScore
                let isSameScoreButFaster = result.score == oldScore && newTime < oldTime
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
    
    // MARK: - Reading (Запрос из единой коллекции через фильтры)
    func fetchTopScores(
        gameType: GameType,
        quizDifficulty: QuizDifficulty,
        level: String,
        countryCode: String? = nil,
        period: RankingPeriod = .allTime
    ) async throws -> [GlobalRankingEntry] {
        
        let scopeLabel = countryCode.map { "country \($0.uppercased())" } ?? "worldwide"
        print("🔍 Запрос рейтинга: \(gameType.rawValue), \(quizDifficulty.questionCount), \(level), \(scopeLabel), \(period.rawValue)")
        
        let baseQuery = db.collection(mainCollection)
            .whereField("gameType", isEqualTo: gameType.rawValue)
            .whereField("total", isEqualTo: quizDifficulty.questionCount)
            .whereField("level", isEqualTo: level)

        let needsClientFilter = period != .allTime || !(countryCode ?? "").isEmpty
        if needsClientFilter {
            let snapshot = try await baseQuery.getDocuments()
            let entries = snapshot.documents.compactMap(decodeEntry)
            return LeaderboardRankingLogic.rank(
                entries,
                countryCode: countryCode,
                since: period.since(),
                limit: AppConfig.Constants.topScores
            )
        }
        
        let snapshot = try await baseQuery
            .order(by: "score", descending: true)
            .order(by: "timeElapsed", descending: false)
            .limit(to: AppConfig.Constants.topScores)
            .getDocuments()
        
        return snapshot.documents.compactMap(decodeEntry)
    }

    private func decodeEntry(from document: QueryDocumentSnapshot) -> GlobalRankingEntry? {
        let data = document.data()
        guard let userId = data["userId"] as? String else { return nil }

        let timestamp: Date
        if let firestoreTimestamp = data["timestamp"] as? Timestamp {
            timestamp = firestoreTimestamp.dateValue()
        } else if let date = data["timestamp"] as? Date {
            timestamp = date
        } else {
            timestamp = .distantPast
        }

        return GlobalRankingEntry(
            id: document.documentID,
            userId: userId,
            userName: data["userName"] as? String ?? "",
            countryCode: data["countryCode"] as? String ?? "",
            score: Self.intValue(data["score"]),
            total: Self.intValue(data["total"]),
            gameType: data["gameType"] as? String ?? "",
            level: data["level"] as? String ?? "",
            category: data["category"] as? String ?? "",
            timeElapsed: Self.doubleValue(data["timeElapsed"]),
            timestamp: timestamp
        )
    }

    private static func intValue(_ value: Any?) -> Int {
        if let intValue = value as? Int { return intValue }
        if let number = value as? NSNumber { return number.intValue }
        return 0
    }

    private static func doubleValue(_ value: Any?, fallback: Double = 0) -> Double {
        if let doubleValue = value as? Double { return doubleValue }
        if let intValue = value as? Int { return Double(intValue) }
        if let number = value as? NSNumber { return number.doubleValue }
        return fallback
    }
}

