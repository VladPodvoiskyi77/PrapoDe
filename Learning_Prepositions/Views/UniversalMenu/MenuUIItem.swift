import SwiftUI

struct MenuUIItem: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String
    let iconColor: Color
    // Полезная нагрузка: мы храним либо категорию, либо режим, чтобы знать, куда переходить
    let payload: MenuPayload
}

enum MenuPayload {
    case category(Category)
    case mode(Activity)
}

