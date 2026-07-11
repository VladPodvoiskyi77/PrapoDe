import SwiftUI
import FirebaseAuth

struct GlobalRankingView: View {
    @StateObject var viewModel: GlobalRankingViewModel
    @ObservedObject private var profileManager = UserProfileManager.shared
    @Environment(\.dismiss) var dismiss
    @Namespace private var animation
    
    init(gameType: GameType, level: Level, quizDifficulty: QuizDifficulty) {
        _viewModel = StateObject(wrappedValue: GlobalRankingViewModel(
            gameType: gameType,
            level: level,
            quizDifficulty: quizDifficulty
        ))
    }
    
    var body: some View {
        ZStack {
            AppTheme.mainGradient.ignoresSafeArea()
            
            VStack(spacing: 16) {
                rankingHeader
                
                Picker("Difficulty", selection: $viewModel.selectedDifficulty) {
                    ForEach(QuizDifficulty.allCases) { diff in
                        Text(diff.title).tag(diff)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: viewModel.selectedDifficulty) { _, _ in
                    refreshData()
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Level.allCases) { level in
                            levelFilterButton(for: level)
                        }
                    }
                    .padding(.horizontal)
                }
                .onChange(of: viewModel.selectedLevel) { _, _ in
                    refreshData()
                }
                
                ZStack {
                    if viewModel.isLoading {
                        CardLoaderView()
                            .frame(maxHeight: .infinity)
                    } else if let error = viewModel.errorMessage {
                        errorStateView(message: error)
                    } else if viewModel.entries.isEmpty {
                        emptyStateView
                    } else {
                        rankingList
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
        .onAppear{
            AnalyticsManager.shared.logScreenView("GlobalRanking")
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.loadRanking()
        }
    }
    
    private func refreshData() {
        Task {
            await viewModel.loadRanking()
        }
    }
    
    // MARK: - Рендер кнопки уровня (как в твоем LeaderboardView)
    @ViewBuilder
    private func levelFilterButton(for level: Level) -> some View {
        let isSelected = viewModel.selectedLevel == level
        
        Text(level.id)
            .font(.system(size: 16, weight: isSelected ? .black : .bold, design: .rounded))
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white)
                            .matchedGeometryEffect(id: "global_level_filter", in: animation)
                    } else {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.15))
                    }
                }
            )
            .foregroundColor(isSelected ? Color(hex: "796fc8") : .white)
            .onTapGesture {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    viewModel.selectedLevel = level
                }
            }
    }
    
    @ViewBuilder
    private var scopeToggleButton: some View {
        if profileManager.isProfileSetupComplete {
            Button {
                Task { await viewModel.toggleScope() }
            } label: {
                Group {
                    if viewModel.scope == .worldwide {
                        Text(viewModel.userCountryFlag)
                            .font(.system(size: 26))
                            .shadow(color: .white.opacity(0.85), radius: 6)
                    } else {
                        Image(systemName: "globe")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 32, height: 32)
            }
            .accessibilityLabel(
                viewModel.scope == .worldwide
                    ? L10n.WorldRanking.Filter.byCountry
                    : L10n.WorldRanking.Filter.worldwide
            )
        }
    }
    
    private var rankingHeader: some View {
        HStack(alignment: .center, spacing: 8) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }
            .frame(width: 44, height: 44)

            Text(L10n.WorldRanking.Sprint.title)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity)

            Group {
                scopeToggleButton
            }
            .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
    }
    
    private var rankingList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                ForEach(Array(viewModel.entries.enumerated()), id: \.element.id) { index, entry in
                    RankingRow(rank: index + 1, entry: entry)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(entry.userId == Auth.auth().currentUser?.uid ? .yellow : Color.clear, lineWidth: 2)
                        )
                        .scaleEffect(entry.userId == Auth.auth().currentUser?.uid ? 1.02 : 1.0)
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.loadRanking()
        }
    }
    
    private func errorStateView(message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Text(message)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button {
                refreshData()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }
            Spacer()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("🚀")
                .font(.system(size: 80))
            Text(L10n.WorldRanking.emptyState)
                .font(.headline)
                .foregroundColor(.white)
            Spacer()
        }
    }
}
