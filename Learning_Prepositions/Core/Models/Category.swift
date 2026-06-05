import SwiftUI

enum Category: String, CaseIterable, Hashable {
    case adjektive = "Adjektive mit Präpositionen"
    case nomen = "Nomen mit Präpositionen"
    case verben = "Verben mit Präpositionen"
    //case all = "Alle Kategorien zusammen"
    
    var fileName: String {
        switch self {
        case .adjektive: return "adjektive"
        case .nomen: return "nomen"
        case .verben: return "verben"
        }
    }
    
    var iconName: String {
        switch self {
        case .adjektive: return "a.square.fill" // A для Adjektive
        case .nomen: return "n.square.fill" // N для Nomen
        case .verben: return "v.square.fill" // V для Verben
        }
    }
    
    var iconColor: Color {
        switch self {
        case .adjektive: return .purple
        case .nomen: return .orange
        case .verben: return .blue
        }
    }
    
}
