import SwiftUI

struct MenuUIItem: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String
    var iconLetter: String? = nil
    let iconColor: Color
    let payload: MenuPayload
    var badgeText: String? = nil
}

enum MenuPayload {
    case category(Category)
    case mode(Activity)
    case prepositionsHub
    case allPrepositions
    case guessCase
}

