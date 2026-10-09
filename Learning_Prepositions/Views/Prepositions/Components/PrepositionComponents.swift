import SwiftUI

struct PrepositionRowCard: View {
    let lemma: String
    let summary: String
    let accentColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Text(lemma)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(accentColor)
                .frame(minWidth: 72, alignment: .leading)
            
            Text(summary)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(AppTheme.primaryText)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
            
            Spacer(minLength: 8)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
        )
    }
}

struct PrepositionSectionHeader: View {
    let title: String
    let subtitle: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }
}

struct PrepositionContentSection: View {
    let title: String
    let icon: String
    let iconColor: Color
    let bodyText: String?
    let bullets: [String]?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(iconColor)
                Text(title)
                    .font(.system(.headline, design: .rounded))
            }
            
            if let bodyText, !bodyText.isEmpty {
                Text(bodyText.markdownAttributedString)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if let bullets, !bullets.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(bullets.enumerated()), id: \.offset) { _, item in
                        Text(item.bulletMarkdownAttributedString)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadow, radius: 6, x: 0, y: 3)
        )
    }
}

struct PrepositionExampleCard: View {
    let german: String
    let translation: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(german)
                .font(.system(.body, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            Text(translation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.primary.opacity(0.04))
        )
    }
}

struct PrepositionDetailSheetItem: Identifiable, Hashable {
    let id: String
    let detailPath: String
    let lemma: String
    let articleSource: PrepositionArticleSource

    init(item: PrepositionIndexItem, articleSource: PrepositionArticleSource) {
        id = item.id
        detailPath = item.detailPath
        lemma = item.lemma
        self.articleSource = articleSource
    }
}

extension View {
    func prepositionDetailSheet(item: Binding<PrepositionDetailSheetItem?>) -> some View {
        sheet(item: item) { detail in
            NavigationStack {
                PrepositionDetailView(
                    prepositionId: detail.id,
                    detailPath: detail.detailPath,
                    lemma: detail.lemma,
                    articleSource: detail.articleSource,
                    onDismiss: { item.wrappedValue = nil }
                )
            }
            .presentationDragIndicator(.visible)
        }
    }
}

struct PrepositionLearnMoreButton: View {
    @EnvironmentObject private var nav: NavigationViewModel

    let lemma: String
    var isProminent: Bool = false
    var articleSource: PrepositionArticleSource = .menu
    var onOpenDetail: ((PrepositionDetailSheetItem) -> Void)? = nil

    @State private var isLoading = false

    var body: some View {
        Button {
            openDetail()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: isProminent ? "book.fill" : "book.circle")
                    .font(.subheadline)

                Text(L10n.Prepositions.learnMore(lemma))
                    .font(.subheadline)
                    .fontWeight(isProminent ? .semibold : .regular)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)

                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            .foregroundStyle(isProminent ? .white : .blue)
            .padding(.horizontal, 16)
            .padding(.vertical, isProminent ? 12 : 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isProminent ? Color.blue : Color.blue.opacity(0.1))
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(isLoading)
    }

    private func openDetail() {
        Task {
            isLoading = true
            defer { isLoading = false }

            guard let item = await PrepositionLookup.shared.indexItem(for: lemma) else { return }
            let sheetItem = PrepositionDetailSheetItem(item: item, articleSource: articleSource)
            if let onOpenDetail {
                onOpenDetail(sheetItem)
            } else {
                nav.goTo(.prepositionDetail(item.id, item.detailPath, item.lemma))
            }
        }
    }
}

extension PrepositionCaseGroup {
    var color: Color {
        switch self {
        case .dativ: return CaseType.dativ.color
        case .akkusativ: return CaseType.akkusativ.color
        case .wechsel: return CaseType.nominativ.color
        case .genitiv: return CaseType.genitiv.color
        }
    }
    
    static func accentColor(for caseGroupId: String) -> Color {
        PrepositionCaseGroup(rawValue: caseGroupId)?.color ?? CaseType.dativ.color
    }
}
