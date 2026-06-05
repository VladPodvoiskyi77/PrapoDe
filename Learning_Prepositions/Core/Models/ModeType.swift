import SwiftUI

enum ModeType: String, CaseIterable {
    case akkusativ
    case dativ
    case random
    case az
    case za
    
    var title: String {
        switch self {
        case .random:
            return L10n.Mode.Case.Random.title
        case .akkusativ:
            return "Akkusativ"
        case .dativ:
            return "Dativ"
        case .az:
            return "A-Z"
        case .za:
            return "Z-A"
        }
    }
    
    var iconName: String {
        switch self {
        case .random: return "shuffle"
        case .akkusativ: return "a.circle.fill"
        case .dativ: return "d.circle.fill"
        case .az: return "arrow.down.circle.fill"
        case .za: return "arrow.up.circle.fill"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .akkusativ: return .blue
        case .dativ:     return .purple
        case .random:   return .indigo
        case .az:       return .orange
        case .za:       return .red
        }
    }
}

extension ModeType {
    static func availableModes(for activity: Activity) -> [ModeType] {
        switch activity {
        case .training:
            return [.akkusativ, .dativ, .random, .az, .za]
        case .quiz, .sprint:
            return [.akkusativ, .dativ, .random]
        case .myProgress, .writing:
            return []
        }
    }
}
