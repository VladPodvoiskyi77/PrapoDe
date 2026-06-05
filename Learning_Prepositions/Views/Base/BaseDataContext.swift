struct BaseDataContext: Equatable, Hashable {
    let wordItems: [WordItem]
    let language: Language
    let category: Category
    let level: Level
    
    init(wordItems: [WordItem],
         language: Language,
         category: Category,
         level: Level) {
        self.wordItems = wordItems
        self.language = language
        self.category = category
        self.level = level
    }
}
