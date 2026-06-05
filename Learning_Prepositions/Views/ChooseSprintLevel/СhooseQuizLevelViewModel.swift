import SwiftUI

@MainActor
final class СhooseQuizLevelViewModel: BaseDataViewModel {
    
    @Published var wordItems: [WordItem] = []
    let categoryName: String
    
    init(items: [WordItem],categoryName: String) {
        self.wordItems = items
        self.categoryName = categoryName
    }
    
}
