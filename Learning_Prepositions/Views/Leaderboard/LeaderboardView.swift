import SwiftUI

struct LeaderboardView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: LeaderboardViewModel
    
    @Namespace private var animation
    
    init(resultContext: ResultContext = ResultContext()) {
        _viewModel = StateObject(wrappedValue: LeaderboardViewModel(resultContext: resultContext))
    }

    var filteredResults: [QuizResult] {
        return viewModel.sortedData()
    }
    
    var body: some View {
        VStack(spacing: 16) {
            
            // MARK: - Заголовок
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .padding()
                }
                Spacer()
                Text(L10n.Leaderboard.title)
                    .font(.title2).bold()
                Spacer()
                Spacer().frame(width: 44)
            }
            .padding(.horizontal)
            
            // MARK: - Фильтр 1: Тип игры
            Picker("Game Type", selection: $viewModel.selectedGameType) {
                ForEach(GameType.allCases) { type in
                    Text(type.title)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // MARK: - Фильтр 2: Сложность (Только для Speed Run)
            if viewModel.selectedGameType == .sprint {
                Picker("Difficulty", selection: $viewModel.selectedDifficulty) {
                    ForEach(QuizDifficulty.allCases) { diff in
                        Text("\(diff.title)").tag(diff)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // MARK: - Фильтр 3: Уровень языка (A1...C1)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Level.allCases) { level in
                        filterButton(for: level)
                    }
                }
                .padding(.horizontal)
            }
            
            // MARK: - Список результатов
            Group {
                if filteredResults.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "list.clipboard")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.3))
                        Text(L10n.Leaderboard.NoResults.description)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(Array(filteredResults.enumerated()), id: \.element.id) { index, result in
                                LeaderboardRow(index: index + 1, result: result)
                                    .transition(.opacity.combined(with: .scale))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.28), value: filteredResults)
            
            Spacer()
        }
        .background(AppTheme.mainGradient.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.selectedGameType)
        .onAppear {
            viewModel.load()
        }
    }
    
    // MARK: - Кнопка фильтра уровня
    @ViewBuilder
    private func filterButton(for level: Level) -> some View {
        let isSelected = viewModel.selectedFilter == level
        
        Text(level.id)
            .font(.callout.weight(isSelected ? .bold : .regular))
            .padding(.vertical, 8)
            .padding(.horizontal, 14)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(level.color.opacity(0.25))
                            .matchedGeometryEffect(id: "filter", in: animation)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                    }
                }
            )
            .foregroundColor(isSelected ? level.color : .primary)
            .onTapGesture {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    viewModel.selectedFilter = level
                }
            }
    }
}
