import SwiftUI

protocol WordValidating {
    func validate(_ items: [WordItem]) -> [WordItem]
}

struct WordValidator: WordValidating {
    func validate(_ items: [WordItem]) -> [WordItem] {
        items.filter { item in
            let hiddenResult = item.example.hidingWord(item.preposition)
            
            let valid = hiddenResult != item.example
            
            if !valid {
                print("❌ Found \(item.basePreposition) invalid: word not found in example")
            }
            return valid
        }
    }
}

