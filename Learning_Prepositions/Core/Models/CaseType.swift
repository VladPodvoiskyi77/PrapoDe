import SwiftUI

enum CaseType: String, CaseIterable, Hashable, Decodable, Encodable {
    case akkusativ = "Akkusativ"
    case dativ = "Dativ"
    case genitiv = "Genitiv"
    case nominativ = "Nominativ"
    
    var shortCaseName: String {
        String(rawValue.prefix(3)).capitalized
    }
}

extension CaseType {
    // Стандартные цвета немецкой грамматики
    var color: Color {
        switch self {
        case .akkusativ: return .blue
        case .dativ: return .green
        case .genitiv: return .orange
        case .nominativ: return .gray
        //case .wechsel: return .purple
        }
    }
}
