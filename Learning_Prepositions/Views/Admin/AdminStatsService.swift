import Foundation
import FirebaseAuth

struct AdminRecentSignup: Identifiable {
    let id: String
    let name: String
    let country: String
    let createdAt: Date
}

struct AdminCountryCount: Identifiable {
    var id: String { country }
    let country: String
    let count: Int
}

struct AdminRecentResult: Identifiable {
    let id: String
    let userName: String
    let countryCode: String
    let gameType: String
    let level: String
    let category: String
    let score: Int
    let total: Int
    let timeElapsed: Double
    let timestamp: Date

    var gameTypeTitle: String {
        switch gameType {
        case "quiz": return "Квиз"
        case "sprint": return "Спринт"
        case "writing": return "Правописание"
        default: return gameType
        }
    }

    var categoryTitle: String {
        if category.localizedCaseInsensitiveContains("Verben") { return "Verben" }
        if category.localizedCaseInsensitiveContains("Adjektive") { return "Adjektive" }
        if category.localizedCaseInsensitiveContains("Nomen") { return "Nomen" }
        return category
    }
}

struct AdminUsageDay: Identifiable {
    var id: String { dateKey }
    let dateKey: String
    let date: String
    let activeUsers: Int
    let newUsers: Int
    let sessions: Int
    let eventCount: Int
    let avgSessionMinutes: Double
    let iosUsers: Int
    let androidUsers: Int
    let modes: [AdminUsageMode]
}

struct AdminUsagePlatform: Identifiable {
    var id: String { name }
    let name: String
    let users: Int
    let newUsers: Int
    let sessions: Int
}

struct AdminUsageMode: Identifiable {
    var id: String { name }
    let name: String
    let started: Int
    let finished: Int

    var title: String {
        switch name {
        case "quiz": return "Quiz"
        case "sprint": return "Sprint"
        case "training": return "Training"
        case "writing": return "Writing"
        default: return name
        }
    }
}

struct AdminUsageReport {
    let days: Int
    let activeUsers: Int
    let newUsers: Int
    let sessions: Int
    let eventCount: Int
    let avgSessionMinutes: Double
    let platforms: [AdminUsagePlatform]
    let daily: [AdminUsageDay]
    let modes: [AdminUsageMode]
}

enum AdminUsageError: LocalizedError {
    case notSignedIn
    case disabled
    case wrongPasscode
    case http(Int)
    case invalidPayload

    var errorDescription: String? {
        switch self {
        case .notSignedIn:
            return "Нет входа в Firebase"
        case .disabled:
            return "Админка сейчас закрыта"
        case .wrongPasscode:
            return "Неверный код"
        case .http(let code):
            return "Не удалось загрузить данные (\(code))"
        case .invalidPayload:
            return "Некорректный ответ аналитики"
        }
    }
}

enum AdminStatsService {
    static let maxRecent = 40
    static let maxRecentResults = 25
    static let signupHistoryDays = 14
    private static let unlockURL = URL(string: "https://us-central1-prapode-bf274.cloudfunctions.net/adminUnlock")!
    private static let directoryURL = URL(string: "https://us-central1-prapode-bf274.cloudfunctions.net/adminDirectory")!
    private static let usageURL = URL(string: "https://us-central1-prapode-bf274.cloudfunctions.net/adminUsage")!

    private static var sessionPasscode: String?
    private static var directory: (users: [AdminRecentSignup], results: [AdminRecentResult])?

    static func unlock(passcode: String) async throws {
        _ = try await post(unlockURL, passcode: passcode)
        sessionPasscode = passcode
        directory = nil
    }

    static func fetchRecentSignups() async throws -> [AdminRecentSignup] {
        try await fetchAllSignups()
            .prefix(maxRecent)
            .map { $0 }
    }

    static func fetchAllSignups() async throws -> [AdminRecentSignup] {
        try await loadDirectory().users
    }

    static func fetchRecentResults() async throws -> [AdminRecentResult] {
        try await loadDirectory().results
    }

    static func fetchCountries() async throws -> [AdminCountryCount] {
        var counts: [String: Int] = [:]
        for user in try await fetchAllSignups() {
            counts[user.country, default: 0] += 1
        }
        return counts
            .map { AdminCountryCount(country: $0.key, count: $0.value) }
            .sorted { lhs, rhs in
                if lhs.count != rhs.count { return lhs.count > rhs.count }
                return lhs.country < rhs.country
            }
    }

    static func fetchUsage() async throws -> AdminUsageReport {
        let data = try await post(usageURL, passcode: sessionPasscode)
        return try parseUsage(data)
    }

    private static func loadDirectory() async throws -> (users: [AdminRecentSignup], results: [AdminRecentResult]) {
        if let directory {
            return directory
        }
        let json = try await postJSON(directoryURL, passcode: sessionPasscode)
        let users = (json["users"] as? [[String: Any]] ?? []).map(parseSignup)
        let results = (json["results"] as? [[String: Any]] ?? []).compactMap(parseResult)
        let loaded = (users, results)
        directory = loaded
        return loaded
    }

    private static func postJSON(_ url: URL, passcode: String?) async throws -> [String: Any] {
        let data = try await post(url, passcode: passcode)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw AdminUsageError.invalidPayload
        }
        return json
    }

    private static func post(_ url: URL, passcode: String?) async throws -> Data {
        guard let user = Auth.auth().currentUser else {
            throw AdminUsageError.notSignedIn
        }
        guard let passcode, !passcode.isEmpty else {
            throw AdminUsageError.wrongPasscode
        }
        let token = try await user.getIDToken()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "passcode": passcode,
            "deviceId": AdminAccess.deviceId,
        ])
        request.timeoutInterval = 45

        let (data, response) = try await URLSession.shared.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        if status == 200 {
            return data
        }
        let error = (try? JSONSerialization.jsonObject(with: data) as? [String: Any])?["error"] as? String
        switch error {
        case "disabled":
            throw AdminUsageError.disabled
        case "passcode":
            throw AdminUsageError.wrongPasscode
        default:
            throw AdminUsageError.http(status)
        }
    }

    private static func parseUsage(_ data: Data) throws -> AdminUsageReport {
        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let totals = json["totals"] as? [String: Any]
        else {
            throw AdminUsageError.invalidPayload
        }

        let platforms = (json["platforms"] as? [[String: Any]] ?? []).map { row in
            AdminUsagePlatform(
                name: row["name"] as? String ?? "—",
                users: intValue(row["users"]),
                newUsers: intValue(row["newUsers"]),
                sessions: intValue(row["sessions"])
            )
        }
        let daily = (json["daily"] as? [[String: Any]] ?? []).map { row in
            let modes = (row["modes"] as? [[String: Any]] ?? []).map { mode in
                AdminUsageMode(
                    name: mode["name"] as? String ?? "",
                    started: intValue(mode["started"]),
                    finished: intValue(mode["finished"])
                )
            }
            return AdminUsageDay(
                dateKey: row["dateKey"] as? String ?? "",
                date: row["date"] as? String ?? "—",
                activeUsers: intValue(row["activeUsers"]),
                newUsers: intValue(row["newUsers"]),
                sessions: intValue(row["sessions"]),
                eventCount: intValue(row["eventCount"]),
                avgSessionMinutes: doubleValue(row["avgSessionMinutes"]),
                iosUsers: intValue(row["iosUsers"]),
                androidUsers: intValue(row["androidUsers"]),
                modes: modes
            )
        }
        let modes = (json["modes"] as? [[String: Any]] ?? []).map { row in
            AdminUsageMode(
                name: row["name"] as? String ?? "",
                started: intValue(row["started"]),
                finished: intValue(row["finished"])
            )
        }

        return AdminUsageReport(
            days: intValue(json["days"]),
            activeUsers: intValue(totals["activeUsers"]),
            newUsers: intValue(totals["newUsers"]),
            sessions: intValue(totals["sessions"]),
            eventCount: intValue(totals["eventCount"]),
            avgSessionMinutes: doubleValue(totals["avgSessionMinutes"]),
            platforms: platforms,
            daily: daily,
            modes: modes
        )
    }

    private static func parseSignup(_ data: [String: Any]) -> AdminRecentSignup {
        AdminRecentSignup(
            id: data["id"] as? String ?? UUID().uuidString,
            name: (data["name"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty ?? "—",
            country: AdminCountryName.canonical((data["country"] as? String) ?? ""),
            createdAt: parseDate(data["createdAt"])
        )
    }

    private static func parseResult(_ data: [String: Any]) -> AdminRecentResult? {
        let timestamp = parseOptionalDate(data["timestamp"])
        guard let timestamp else { return nil }
        return AdminRecentResult(
            id: data["id"] as? String ?? UUID().uuidString,
            userName: (data["userName"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty ?? "—",
            countryCode: (data["countryCode"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty ?? "—",
            gameType: (data["gameType"] as? String) ?? "",
            level: (data["level"] as? String) ?? "—",
            category: (data["category"] as? String) ?? "—",
            score: intValue(data["score"]),
            total: intValue(data["total"]),
            timeElapsed: doubleValue(data["timeElapsed"]),
            timestamp: timestamp
        )
    }

    private static func parseDate(_ raw: Any?) -> Date {
        parseOptionalDate(raw) ?? .distantPast
    }

    private static func parseOptionalDate(_ raw: Any?) -> Date? {
        if let number = raw as? NSNumber {
            let value = number.doubleValue
            return Date(timeIntervalSince1970: value > 10_000_000_000 ? value / 1000 : value)
        }
        if let millis = raw as? Int64 {
            return Date(timeIntervalSince1970: TimeInterval(millis) / 1000)
        }
        if let millis = raw as? Int {
            return Date(timeIntervalSince1970: TimeInterval(millis) / 1000)
        }
        if let value = raw as? Double {
            return Date(timeIntervalSince1970: value > 10_000_000_000 ? value / 1000 : value)
        }
        return nil
    }

    private static func intValue(_ raw: Any?) -> Int {
        if let value = raw as? Int { return value }
        if let value = raw as? Int64 { return Int(value) }
        if let value = raw as? NSNumber { return value.intValue }
        return 0
    }

    private static func doubleValue(_ raw: Any?) -> Double {
        if let value = raw as? Double { return value }
        if let value = raw as? NSNumber { return value.doubleValue }
        return 0
    }
}

enum AdminCountryName {
    static func canonical(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty || trimmed == "—" { return "—" }

        let key = fold(trimmed)
        if key.count == 2, let name = russianName(forISO: key.uppercased()) {
            return name
        }
        if let iso = extraAliases[key] ?? isoByLocalizedName[key] {
            return russianName(forISO: iso) ?? trimmed
        }
        return trimmed
    }

    private static func russianName(forISO code: String) -> String? {
        Locale(identifier: "ru").localizedString(forRegionCode: code)
            ?? Locale(identifier: "en").localizedString(forRegionCode: code)
    }

    private static func fold(_ value: String) -> String {
        value
            .folding(options: [.diacriticInsensitive, .caseInsensitive, .widthInsensitive], locale: .current)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }

    private static let extraAliases: [String: String] = [
        "deutschland": "DE",
        "фрг": "DE",
        "brd": "DE",
        "allemagne": "DE",
        "germany": "DE",
        "юкрейн": "UA",
        "ukraina": "UA",
        "ukrajina": "UA",
        "usa": "US",
        "us": "US",
        "сша": "US",
        "america": "US",
        "united states": "US",
        "united states of america": "US",
        "holland": "NL",
        "nederland": "NL",
        "turkiye": "TR",
        "turkey": "TR",
        "egypt": "EG",
        "agypten": "EG",
        "norwegen": "NO",
        "russland": "RU",
        "uae": "AE",
        "uk": "GB",
        "great britain": "GB",
        "england": "GB",
        "korea": "KR",
        "south korea": "KR",
    ]

    private static let isoByLocalizedName: [String: String] = {
        let locales = ["ru", "uk", "en", "de", "fr"].map(Locale.init(identifier:))
        var map: [String: String] = [:]
        let codes: [String]
        if #available(iOS 16.0, *) {
            codes = Locale.Region.isoRegions.map(\.identifier)
        } else {
            codes = Locale.isoRegionCodes
        }
        for code in codes where code.count == 2 {
            map[fold(code)] = code
            for locale in locales {
                if let name = locale.localizedString(forRegionCode: code) {
                    map[fold(name)] = code
                }
            }
        }
        return map
    }()
}

private extension String {
    var nonEmpty: String? { isEmpty ? nil : self }
}
