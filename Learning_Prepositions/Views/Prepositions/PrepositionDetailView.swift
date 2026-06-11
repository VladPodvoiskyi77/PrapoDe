import SwiftUI

struct PrepositionDetailView: View {
    @StateObject private var viewModel: PrepositionDetailViewModel
    @State private var showConfirmUpdate = false
    
    init(prepositionId: String, detailPath: String, lemma: String) {
        _viewModel = StateObject(
            wrappedValue: PrepositionDetailViewModel(
                prepositionId: prepositionId,
                detailPath: detailPath,
                lemma: lemma
            )
        )
    }
    
    var body: some View {
        ZStack {
            AppTheme.mainGradient.ignoresSafeArea()
            
            if viewModel.isLoading && viewModel.detail == nil {
                CardLoaderView()
            } else if let content = viewModel.localizedContent {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        heroHeader(content: content)
                        
                        PrepositionContentSection(
                            title: L10n.Prepositions.Detail.meaning,
                            icon: "text.book.closed.fill",
                            iconColor: .blue,
                            bodyText: content.meaning,
                            bullets: nil
                        )
                        
                        if let notes = content.grammarNotes, !notes.isEmpty {
                            PrepositionContentSection(
                                title: L10n.Prepositions.Detail.grammar,
                                icon: "graduationcap.fill",
                                iconColor: .indigo,
                                bodyText: nil,
                                bullets: notes
                            )
                        }
                        
                        if let detail = viewModel.detail, detail.caseGroup == "wechsel" {
                            wechselSections(detail: detail, content: content)
                        }
                        
                        if let uses = content.whenToUse, !uses.isEmpty {
                            PrepositionContentSection(
                                title: L10n.Prepositions.Detail.whenToUse,
                                icon: "lightbulb.fill",
                                iconColor: .yellow,
                                bodyText: nil,
                                bullets: uses
                            )
                        }
                        
                        if let mistakes = content.commonMistakes, !mistakes.isEmpty {
                            PrepositionContentSection(
                                title: L10n.Prepositions.Detail.mistakes,
                                icon: "exclamationmark.triangle.fill",
                                iconColor: .orange,
                                bodyText: nil,
                                bullets: mistakes
                            )
                        }
                        
                        if let contrasts = content.contrastWith, !contrasts.isEmpty {
                            contrastSection(contrasts)
                        }
                        
                        if viewModel.detail?.caseGroup != "wechsel" {
                            examplesSection(
                                title: L10n.Prepositions.Detail.examples,
                                examples: content.examples ?? []
                            )
                        }
                        
                        if let related = viewModel.detail?.relatedPrepositions, !related.isEmpty {
                            relatedSection(related)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            
            if viewModel.isUpdating {
                ZStack {
                    Color.black.opacity(0.2).ignoresSafeArea()
                    CardLoaderView()
                }
            }
        }
        .opacity(viewModel.isUpdating ? 0.5 : 1)
        .disabled(viewModel.isUpdating)
        .navigationTitle(viewModel.lemma)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showConfirmUpdate = true
                } label: {
                    Image(systemName: "arrow.clockwise.icloud")
                        .fontWeight(.medium)
                }
                .disabled(viewModel.detail == nil)
            }
        }
        .task {
            await viewModel.loadDetail()
        }
        .errorAlert(isPresented: $viewModel.showError, error: viewModel.appError) {
            Task { await viewModel.loadDetail() }
        }
        .showAlert(
            title: L10n.Prepositions.Detail.Update.Alert.Confirm.title,
            description: L10n.Prepositions.Detail.Update.Alert.Confirm.description,
            isPresented: $showConfirmUpdate
        ) {
            Task { await viewModel.refreshDetail() }
        }
        .statusAlert(
            title: viewModel.statusAlertTitle,
            description: viewModel.statusAlertDescription,
            isPresented: $viewModel.showStatusAlert
        )
        .onAppear {
            AnalyticsManager.shared.logScreenView("PrepositionDetail")
        }
    }
    
    @ViewBuilder
    private func heroHeader(content: PrepositionLocalizedContent) -> some View {
        let caseText = viewModel.detail?.caseLabel?.text(for: viewModel.selectedLanguage)
        
        VStack(spacing: 12) {
            Text(content.title)
                .font(.system(size: 52, weight: .black, design: .rounded))
                .foregroundStyle(
                    PrepositionCaseGroup.accentColor(
                        for: viewModel.detail?.caseGroup ?? ""
                    )
                )
            
            if let caseText, !caseText.isEmpty {
                Text(caseText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppTheme.cardBackground)
                .shadow(color: AppTheme.cardShadow, radius: 10, x: 0, y: 5)
        )
        .padding(.top, 8)
    }
    
    @ViewBuilder
    private func wechselSections(detail: PrepositionDetail, content: PrepositionLocalizedContent) -> some View {
        let language = viewModel.selectedLanguage
        
        if let dativLabel = detail.wechselRules?.dativ?.labels?.text(for: language) {
            examplesSection(
                title: dativLabel,
                examples: viewModel.examples(for: "dativ")
            )
        }
        
        if let akkLabel = detail.wechselRules?.akkusativ?.labels?.text(for: language) {
            examplesSection(
                title: akkLabel,
                examples: viewModel.examples(for: "akkusativ")
            )
        }
        
        if viewModel.examples(for: "dativ").isEmpty,
           viewModel.examples(for: "akkusativ").isEmpty,
           let examples = content.examples,
           !examples.isEmpty {
            examplesSection(title: L10n.Prepositions.Detail.examples, examples: examples)
        }
    }
    
    @ViewBuilder
    private func examplesSection(title: String, examples: [PrepositionExample]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "quote.bubble.fill")
                    .font(.title3)
                    .foregroundStyle(.green)
                Text(title)
                    .font(.system(.headline, design: .rounded))
            }
            
            VStack(spacing: 10) {
                ForEach(examples) { example in
                    PrepositionExampleCard(
                        german: example.de,
                        translation: example.translation ?? ""
                    )
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
    
    @ViewBuilder
    private func contrastSection(_ contrasts: [PrepositionContrast]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.title3)
                    .foregroundStyle(.purple)
                Text(L10n.Prepositions.Detail.contrast)
                    .font(.system(.headline, design: .rounded))
            }
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(contrasts) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.preposition)
                            .font(.subheadline.bold())
                        Text(item.note.markdownAttributedString)
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
    
    @ViewBuilder
    private func relatedSection(_ related: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Prepositions.Detail.related)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            
            Text(related.joined(separator: " · "))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }
}
