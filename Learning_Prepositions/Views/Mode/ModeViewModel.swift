import SwiftUI

@MainActor
final class ModeViewModel: BaseDataViewModel {
    
    // MARK: - Dependencies
    private let category: Category
    var allWords: [WordItem] = []
    
    @Published var availableModes: [ModeType] = []
    
    init(category: Category, appMode: Activity) {
        self.category = category
        super.init()
        
        self.availableModes = ModeType.availableModes(for: appMode)
    }
    
    // MARK: - Logic
    func prepareWords(for mode: ModeType) async -> [WordItem]? {
        // 1. Если кэш пуст, загружаем
        if allWords.isEmpty {
            guard let loaded = await performLoad(category: category) else {
                return nil
            }
            self.allWords = loaded
        }
        
        return filterWords(allWords, mode: mode)
    }
    
    // MARK: - Private Helper
    private func filterWords(_ words: [WordItem], mode: ModeType) -> [WordItem] {
        switch mode {
        case .random:
            return words.shuffled()
        case .akkusativ, .dativ:
            return words.filter { $0.caseType == mode.title }.shuffled()
        case .az:
            return words.sorted(by: { $0.base > $1.base })
        case .za:
            return words.sorted(by: { $0.base < $1.base })
        }
    }
}
