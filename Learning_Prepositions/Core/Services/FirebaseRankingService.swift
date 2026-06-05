import FirebaseFirestore
//
//protocol GlobalRankingProviding {
//    func fetchTopScores(gameType: GameType, level: String, category: String) async throws -> [GlobalRankingEntry]
//}

//final class FirebaseRankingService: GlobalRankingProviding {
//    private let db = Firestore.firestore()
//    
//    func fetchTopScores(gameType: GameType, level: String, category: String) async throws -> [GlobalRankingEntry] {
//        // Мы ищем записи по конкретной категории, уровню и типу игры
//        let snapshot = try await db.collection("leaderboard_records")
//            .whereField("gameType", isEqualTo: gameType.rawValue)
//            .whereField("level", isEqualTo: level)
//            .whereField("category", isEqualTo: category)
//            .order(by: "score", descending: true)      // Сначала больше очков
//            .order(by: "timeElapsed", descending: false) // При равных очках — кто быстрее
//            .limit(to: 50) // Берем Топ-50
//            .getDocuments()
//        
//        return snapshot.documents.compactMap { document in
//            try? document.data(as: GlobalRankingEntry.self)
//        }
//    }
//}
