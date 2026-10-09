import SwiftUI

enum CaseType: String, CaseIterable, Hashable, Decodable, Encodable {
    case akkusativ = "Akkusativ"
    case dativ = "Dativ"
    case genitiv = "Genitiv"
    case nominativ = "Nominativ"
    
    var shortCaseName: String {
        String(rawValue.prefix(3)).capitalized
    }

    static let quizCases: [CaseType] = [.akkusativ, .dativ, .genitiv]

    static func quizCase(from raw: String) -> CaseType? {
        let type = raw.lowercased()
        if type.contains("akk") { return .akkusativ }
        if type.contains("dat") { return .dativ }
        if type.contains("gen") { return .genitiv }
        return nil
    }
}

extension CaseType {
    /// Shared case palette for the whole app (training, quiz, progress, widget).
    var color: Color {
        switch self {
        case .akkusativ: return Color(red: 1, green: 149 / 255, blue: 0)
        case .dativ: return Color(red: 175 / 255, green: 82 / 255, blue: 222 / 255)
        case .nominativ: return Color(red: 48 / 255, green: 176 / 255, blue: 199 / 255)
        case .genitiv: return Color(red: 0, green: 122 / 255, blue: 1)
        }
    }
}
