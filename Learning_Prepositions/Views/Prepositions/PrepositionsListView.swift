import SwiftUI

struct PrepositionsListView: View {
    @StateObject private var viewModel = PrepositionsListViewModel()
    @EnvironmentObject private var nav: NavigationViewModel
    
    var body: some View {
        ZStack {
            AppTheme.mainGradient.ignoresSafeArea()
            
            if viewModel.isLoading && viewModel.sections.isEmpty {
                CardLoaderView()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        header
                        
                        ForEach(viewModel.sections) { section in
                            sectionView(section)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
            
            if viewModel.isLoading && !viewModel.sections.isEmpty {
                ZStack {
                    Color.black.opacity(0.2).ignoresSafeArea()
                    CardLoaderView()
                }
            }
        }
        .navigationTitle(L10n.Prepositions.List.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadIndex()
        }
        .errorAlert(isPresented: $viewModel.showError, error: viewModel.appError) {
            Task { await viewModel.loadIndex() }
        }
        .onAppear {
            AnalyticsManager.shared.logScreenView("PrepositionsList")
        }
    }
    
    private var header: some View {
        VStack(spacing: 8) {
            Text(L10n.Prepositions.List.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
    }
    
    @ViewBuilder
    private func sectionView(_ section: PrepositionListSection) -> some View {
        let language = viewModel.selectedLanguage
        let accent = PrepositionCaseGroup.accentColor(for: section.group.id)
        
        VStack(alignment: .leading, spacing: 12) {
            PrepositionSectionHeader(
                title: section.group.titles.text(for: language),
                subtitle: section.group.subtitles?.text(for: language)
            )
            
            VStack(spacing: 10) {
                ForEach(section.items) { item in
                    Button {
                        nav.goTo(.prepositionDetail(item.id, item.detailPath, item.lemma))
                    } label: {
                        PrepositionRowCard(
                            lemma: item.lemma,
                            summary: item.summary.text(for: language),
                            accentColor: accent
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
    }
}
