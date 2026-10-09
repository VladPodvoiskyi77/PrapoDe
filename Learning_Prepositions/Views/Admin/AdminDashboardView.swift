import SwiftUI

enum AdminPage {
    case menu
    case registrations
    case results
    case countries
    case daily
}

struct AdminDashboardView: View {
    var onOpen: (AdminPage) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Аналитика")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.top, 64)

            VStack(spacing: 0) {
                menuRow("Последние регистрации") { onOpen(.registrations) }
                menuDivider
                menuRow("Последние результаты") { onOpen(.results) }
                menuDivider
                menuRow("Страны") { onOpen(.countries) }
                menuDivider
                menuRow("Аналитика по дням") { onOpen(.daily) }
            }
            .background(AdminChrome.cardBackground)

            Spacer()
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func menuRow(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.45))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
        }
        .buttonStyle(.plain)
    }

    private var menuDivider: some View {
        Divider().overlay(Color.white.opacity(0.12))
    }
}

struct AdminRecentUsersView: View {
    var onBack: () -> Void

    @State private var users: [AdminRecentSignup] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        AdminListScreen(title: "Последние регистрации", onBack: onBack) {
            if isLoading {
                AdminLoadingState()
            } else if let errorMessage {
                AdminMessageState(errorMessage)
            } else if users.isEmpty {
                AdminMessageState("Пока нет регистраций")
            } else {
                AdminCardList(count: users.count) { index in
                    let user = users[index]
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.name)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                            Text(user.country)
                                .font(.system(size: 14))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        Spacer()
                        Text(AdminChrome.dateTime.string(from: user.createdAt))
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.5))
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
        }
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        do {
            users = try await AdminStatsService.fetchRecentSignups()
        } catch {
            errorMessage = "Не удалось загрузить список. \(error.localizedDescription)"
        }
        isLoading = false
    }
}

struct AdminRecentResultsView: View {
    var onBack: () -> Void

    @State private var results: [AdminRecentResult] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        AdminListScreen(title: "Последние результаты", onBack: onBack) {
            if isLoading {
                AdminLoadingState()
            } else if let errorMessage {
                AdminMessageState(errorMessage)
            } else if results.isEmpty {
                AdminMessageState("Пока нет записей в рейтинге")
            } else {
                Text("Лучшие рекорды в рейтинге, не каждая сессия")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.bottom, 4)

                AdminCardList(count: results.count) { index in
                    let result = results[index]
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(result.userName)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                            Spacer()
                            Text("\(result.score)/\(result.total)")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        Text(resultLine(result))
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.7))
                        Text(AdminChrome.dateTime.string(from: result.timestamp))
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.45))
                    }
                }
            }
        }
        .task { await load() }
    }

    private func resultLine(_ result: AdminRecentResult) -> String {
        var parts = [result.gameTypeTitle, result.level, result.categoryTitle, result.countryCode]
        if result.gameType == "sprint", result.timeElapsed > 0 {
            parts.append(String(format: "%.1f с", result.timeElapsed))
        }
        return parts.joined(separator: " · ")
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        do {
            results = try await AdminStatsService.fetchRecentResults()
        } catch {
            errorMessage = "Не удалось загрузить результаты. \(error.localizedDescription)"
        }
        isLoading = false
    }
}

struct AdminCountriesView: View {
    var onBack: () -> Void

    @State private var countries: [AdminCountryCount] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        AdminListScreen(title: "Страны", onBack: onBack) {
            if isLoading {
                AdminLoadingState()
            } else if let errorMessage {
                AdminMessageState(errorMessage)
            } else if countries.isEmpty {
                AdminMessageState("Пока нет данных")
            } else {
                AdminCardList(count: countries.count) { index in
                    let item = countries[index]
                    HStack {
                        Text(item.country)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.white)
                        Spacer()
                        Text("\(item.count)")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
        }
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        do {
            countries = try await AdminStatsService.fetchCountries()
        } catch {
            errorMessage = "Не удалось загрузить страны. \(error.localizedDescription)"
        }
        isLoading = false
    }
}

struct AdminDailyAnalyticsView: View {
    var onBack: () -> Void

    @State private var days: [Date] = []
    @State private var selectedDay: Date = Calendar.current.startOfDay(for: Date())
    @State private var users: [AdminRecentSignup] = []
    @State private var usage: AdminUsageReport?
    @State private var isLoading = true
    @State private var errorMessage: String?

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Berlin") ?? .current
        return calendar
    }

    private var selectedUsers: [AdminRecentSignup] {
        users.filter { calendar.isDate($0.createdAt, inSameDayAs: selectedDay) }
    }

    private var selectedUsage: AdminUsageDay? {
        let key = AdminChrome.dayKey.string(from: selectedDay)
        return usage?.daily.first { $0.dateKey == key }
    }

    var body: some View {
        AdminListScreen(title: "Аналитика по дням", onBack: onBack) {
            if isLoading {
                AdminLoadingState()
            } else if let errorMessage {
                AdminMessageState(errorMessage)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        dateCarousel

                        Text(AdminChrome.selectedDay.string(from: selectedDay).capitalized)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))

                        if let selectedUsage {
                            usageBlock(selectedUsage)
                        } else {
                            Text("Нет данных использования за этот день")
                                .font(.system(size: 14))
                                .foregroundStyle(.white.opacity(0.65))
                        }

                        Text("Новые профили · \(selectedUsers.count)")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.top, 8)

                        if selectedUsers.isEmpty {
                            Text("В этот день профилей не создавали")
                                .font(.system(size: 14))
                                .foregroundStyle(.white.opacity(0.65))
                        } else {
                            AdminCardStack(count: selectedUsers.count) { index in
                                let user = selectedUsers[index]
                                HStack(alignment: .firstTextBaseline) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(user.name)
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundStyle(.white)
                                        Text(user.country)
                                            .font(.system(size: 14))
                                            .foregroundStyle(.white.opacity(0.7))
                                    }
                                    Spacer()
                                    Text(AdminChrome.dateTime.string(from: user.createdAt))
                                        .font(.system(size: 12))
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                            }
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .task { await load() }
    }

    private var dateCarousel: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(days, id: \.self) { day in
                        let selected = calendar.isDate(day, inSameDayAs: selectedDay)
                        Button {
                            selectedDay = day
                        } label: {
                            VStack(spacing: 4) {
                                Text(AdminChrome.weekday.string(from: day).uppercased())
                                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                                Text(AdminChrome.dayNumber.string(from: day))
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(selected ? .black : .white)
                            .frame(width: 52, height: 64)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(selected ? Color.white : Color.white.opacity(0.14))
                            )
                        }
                        .buttonStyle(.plain)
                        .id(day)
                    }
                }
            }
            .onAppear {
                proxy.scrollTo(selectedDay, anchor: .trailing)
            }
            .onChange(of: days) { _, _ in
                proxy.scrollTo(selectedDay, anchor: .trailing)
            }
        }
    }

    private func usageBlock(_ day: AdminUsageDay) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Использование")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)

            usageLine("Юзеры", "\(day.activeUsers)")
            usageLine("Новые", "\(day.newUsers)")
            usageLine("Сессии", "\(day.sessions)")
            usageLine("События", "\(day.eventCount)")
            usageLine("Средняя сессия", String(format: "%.0f мин", day.avgSessionMinutes))
            usageLine("iOS / Android", "\(day.iosUsers) / \(day.androidUsers)")

            if !day.modes.isEmpty {
                Divider().overlay(Color.white.opacity(0.12))
                ForEach(day.modes) { mode in
                    usageLine(mode.title, "\(mode.started) → \(mode.finished)")
                }
            }
        }
        .padding(16)
        .background(AdminChrome.cardBackground)
    }

    private func usageLine(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        let today = calendar.startOfDay(for: Date())
        selectedDay = today
        days = (0..<AdminStatsService.signupHistoryDays).compactMap { offset in
            calendar.date(byAdding: .day, value: offset - (AdminStatsService.signupHistoryDays - 1), to: today)
        }

        do {
            async let usersTask = AdminStatsService.fetchAllSignups()
            async let usageTask = AdminStatsService.fetchUsage()
            users = try await usersTask
            usage = try await usageTask
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

private enum AdminChrome {
    static let dateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    static let dayNumber: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "Europe/Berlin")
        formatter.dateFormat = "d"
        return formatter
    }()

    static let weekday: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.timeZone = TimeZone(identifier: "Europe/Berlin")
        formatter.dateFormat = "EE"
        return formatter
    }()

    static let selectedDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.timeZone = TimeZone(identifier: "Europe/Berlin")
        formatter.dateFormat = "d MMMM, EEEE"
        return formatter
    }()

    static let dayKey: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Europe/Berlin")
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()

    static var cardBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(.white.opacity(0.14))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.white.opacity(0.18), lineWidth: 1)
            )
    }
}

private struct AdminListScreen<Content: View>: View {
    let title: String
    var onBack: () -> Void
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button(action: onBack) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text(title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .padding(.top, 56)

            content()
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct AdminLoadingState: View {
    var body: some View {
        ProgressView()
            .tint(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct AdminMessageState: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.system(size: 15))
            .foregroundStyle(.white.opacity(0.85))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct AdminCardList<Row: View>: View {
    let count: Int
    @ViewBuilder var row: (Int) -> Row

    var body: some View {
        ScrollView(showsIndicators: false) {
            AdminCardStack(count: count) { index in
                row(index)
            }
            .padding(.bottom, 24)
        }
    }
}

private struct AdminCardStack<Row: View>: View {
    let count: Int
    @ViewBuilder var row: (Int) -> Row

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<count, id: \.self) { index in
                row(index)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                if index < count - 1 {
                    Divider().overlay(Color.white.opacity(0.12))
                }
            }
        }
        .background(AdminChrome.cardBackground)
    }
}
