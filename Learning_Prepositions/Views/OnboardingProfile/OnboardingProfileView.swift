import SwiftUI

struct OnboardingProfileView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var profileManager = UserProfileManager.shared
    
    @State private var nickname: String = ""
    @State private var selectedCountry: Country?
    @State private var searchText: String = ""
    @State private var showCountryPicker = false
    
    var filteredCountries: [Country] {
        if searchText.isEmpty { return Country.allCountries }
        return Country.allCountries.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var isDataValid: Bool {
        nickname.trimmingCharacters(in: .whitespaces).count >= 3 && selectedCountry != nil
    }

    var body: some View {
        ZStack {
            // Фон реагирует на касание и закрывает клавиатуру
            AppTheme.mainGradient
                .ignoresSafeArea()
                .onTapGesture {
                    hideKeyboard()
                }
            
            VStack(spacing: 30) {
                // MARK: - Header
                VStack(spacing: 12) {
                    Text("🌎")
                        .font(.system(size: 70))
                    
                    Text(L10n.OnboardingProfile.title)
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(L10n.OnboardingProfile.subtitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.top, 40)

                VStack(spacing: 20) {
                    // Поле Никнейма
                    inputContainer(title: L10n.OnboardingProfile.Nickname.label) {
                        TextField(L10n.OnboardingProfile.Nickname.placeholder, text: $nickname)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .autocorrectionDisabled()
                    }

                    // Поле Страны
                    inputContainer(title: L10n.OnboardingProfile.Country.label) {
                        Button {
                            hideKeyboard()
                            showCountryPicker = true
                        } label: {
                            HStack {
                                if let country = selectedCountry {
                                    Text("\(country.flag) \(country.name)")
                                        .foregroundColor(.black)
                                } else {
                                    Text(L10n.OnboardingProfile.Country.placeholder)
                                        .foregroundColor(.black.opacity(0.4))
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.black.opacity(0.3))
                            }
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        }
                    }
                }
                .padding(.horizontal, 25)

                Spacer()
                
                // Кнопка сохранения
                AppButton(
                    title: L10n.OnboardingProfile.saveButton,
                    minHeight: 60,
                    background: isDataValid ? .yellow : .white.opacity(0.4)
                ) {
                    if let country = selectedCountry {
                        profileManager.setupProfile(
                            name: nickname,
                            countryName: country.name,
                            countryCode: country.id
                        )
                        dismiss()
                    }
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 40)
                .disabled(!isDataValid)
            }
        }
        .sheet(isPresented: $showCountryPicker) {
            countrySelectionList
        }
        .onAppear {
            AnalyticsManager.shared.logProfileSetupStarted()
        }
    }

    // Универсальный контейнер для полей ввода
    private func inputContainer<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
                .padding(.leading, 5)
            
            content()
                .padding(.all, 20)
                .background(Color.white)
                .cornerRadius(18)
        }
    }

    // Список выбора страны
    var countrySelectionList: some View {
        NavigationView {
            List(filteredCountries) { country in
                Button {
                    selectedCountry = country
                    showCountryPicker = false
                } label: {
                    HStack {
                        Text(country.flag)
                        Text(country.name)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                }
            }
            .navigationTitle(L10n.OnboardingProfile.Picker.title)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: L10n.OnboardingProfile.Picker.search)
            .preferredColorScheme(.light)
        }
    }
}
