import SwiftUI

enum RulesContext {
    case general
    case writing
    var title: String {
        switch self {
        case .general: return L10n.Rules.title
        case .writing: return L10n.Writing.Rules.title
        }
    }

    var items: [RuleItem] {
        switch self {
        case .general:
            return [
                RuleItem(
                    icon: "target",
                    color: .blue,
                    title: L10n.Rules.Target.title,
                    description: L10n.Rules.Target.description
                ),

                RuleItem(
                    icon: "gamecontroller.fill",
                    color: .purple,
                    title: L10n.Rules.Where.title,
                    description: L10n.Rules.Where.description
                ),

                RuleItem(
                    icon: "checkmark.circle.fill",
                    color: .green,
                    title: L10n.Rules.Correct.title,
                    description: L10n.Rules.Correct.description
                ),

                RuleItem(
                    icon: "xmark.circle.fill",
                    color: .red,
                    title: L10n.Rules.Wrong.title,
                    description: L10n.Rules.Wrong.description
                )
 
            ]
        case .writing:
            return [
                RuleItem(
                    icon: "keyboard",
                    color: .blue,
                    title: L10n.Rules.Writing.Case.title,
                    description: L10n.Rules.Writing.Case.desc
                ),
                RuleItem(
                    icon: "character.bubble.fill",
                    color: .orange,
                    title: L10n.Rules.Writing.Umlauts.title,
                    description: L10n.Rules.Writing.Umlauts.desc
                ),
                RuleItem(
                    icon: "person.fill.checkmark",
                    color: .green,
                    title: L10n.Rules.Writing.Sich.title,
                    description: L10n.Rules.Writing.Sich.desc
                ),
                RuleItem(
                    icon: "checkmark.circle.fill",
                    color: .green,
                    title: L10n.Rules.Correct.title,
                    description: L10n.Rules.Correct.description
                ),
            ]
        }
    }
}
