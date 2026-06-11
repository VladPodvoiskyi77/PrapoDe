import Foundation
import SwiftUI

// MARK: - Поддерживаемые языки

enum Level: String, CaseIterable, Identifiable, Decodable, Encodable {
    case a1 = "A1"
    case a2 = "A2"
    case b1 = "B1"
    case b2 = "B2"
    case c1 = "C1"
    
    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .a1: return "🐣"
        case .a2: return "🌱"
        case .b1: return "🚶‍♂️"
        case .b2: return "🦊"
        case .c1: return "🧠"
        }
    }
}

extension Level {
    var color: Color {
        switch self {
        case .a1: return .mint
        case .a2: return .teal
        case .b1: return .blue
        case .b2: return .indigo
        case .c1: return .orange
        }
    }
}
