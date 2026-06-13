import SwiftUI

struct MenuUIItem: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String
    let iconColor: Color
    let payload: MenuPayload
}

enum MenuPayload {
    case category(Category)
    case mode(Activity)
}

