import SwiftUI

struct Evaluation {
    let result: WritingResult
    let matchedTarget: String}

class GermanResponseEvaluator {
    func evaluate(input: String, targets: [String], normalize: (String) -> String) -> Evaluation {
        if let perfect = targets.first(where: { normalize($0) == input }) {
            return Evaluation(result: .perfect, matchedTarget: perfect)
        }
        
        for target in targets {
            let targetNorm = normalize(target)
            if input.isEquivalentIgnoringUmlauts(to: targetNorm) {
                let status = checkUmlauts(input: input, target: targetNorm)
                return Evaluation(result: status, matchedTarget: target)
            }
        }
        
        return Evaluation(result: .wrong, matchedTarget: targets.first ?? "")
    }
    
    private func checkUmlauts(input: String, target: String) -> WritingResult {
        var hasExtra = false
        var hasMissing = false
        let umlauts = "äöüß"
        
        for (i, t) in zip(input, target) {
            if i != t {
                if umlauts.contains(i) && !umlauts.contains(t) { hasExtra = true }
                if !umlauts.contains(i) && umlauts.contains(t) { hasMissing = true }
            }
        }
        
        if hasExtra && !hasMissing { return .extraUmlaut }
        if hasMissing && !hasExtra { return .missingUmlaut }
        return .missingUmlaut
        }
}
