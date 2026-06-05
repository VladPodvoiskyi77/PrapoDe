import SwiftUI

struct Country: Identifiable, Hashable {
    let id: String // ISO код (UA, DE, US...)
    let name: String
    let flag: String
    
    static var allCountries: [Country] {
        let allCodes: [String]
        if #available(iOS 16.0, *) {
            allCodes = Locale.Region.isoRegions.map { $0.identifier }
        } else {
            allCodes = Locale.isoRegionCodes
        }
        
        let excluded = ["EU", "EZ", "UN", "QO", "AN"]

        return allCodes.compactMap { code in
            guard code.count == 2,
                  code.rangeOfCharacter(from: CharacterSet.letters.inverted) == nil,
                  !excluded.contains(code.uppercased()) else {
                return nil
            }
            
            let name = Locale.current.localizedString(forRegionCode: code) ?? code
            
            let flag = code.uppercased().unicodeScalars.reduce("") { res, scalar in
                guard let flagScalar = UnicodeScalar(127397 + scalar.value) else { return res }
                return res + String(flagScalar)
            }
            
            return Country(id: code, name: name, flag: flag)
        }
        .sorted { (country1, country2) -> Bool in
            // Использование localizedStandardCompare решает проблему с Є, І, Ї
            // и правильно расставляет страны в алфавитном порядке выбранного языка
            return country1.name.localizedStandardCompare(country2.name) == .orderedAscending
        }
    }
}
