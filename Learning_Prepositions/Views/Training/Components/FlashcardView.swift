import SwiftUI

struct FlashcardView: View {
    let word: WordItem
    
    @State private var isFlipped = false
    @State private var dragOffset: CGSize = .zero
    
    // Callbacks
    var onRemove: (() -> Void)?
    var onReturn: (() -> Void)?
    
    @AppStorage("selectedLanguage", store: UserDefaults(suiteName: AppConfig.Constants.appGroupID))
    private var selectedLanguageRawValue = Language.en.rawValue
    
    var currentLanguage: Language {
        Language(rawValue: selectedLanguageRawValue) ?? .en
    }
    
    var accentColor: Color {
        return word.caseType.caseColor
    }
    
    var body: some View {
        ZStack {
            // --- ОСНОВА КАРТОЧКИ ---
            RoundedRectangle(cornerRadius: 32) // Более скругленные углы (Modern look)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6) // Глубокая тень
                .overlay(
                    // Цветная обводка (индикатор падежа)
                    RoundedRectangle(cornerRadius: 32)
                        .strokeBorder(
                            LinearGradient(
                                colors: [accentColor.opacity(0.6), accentColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                )
            
            // --- КОНТЕНТ ---
            ZStack {
                backSideContent
                    .opacity(isFlipped ? 1 : 0)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                
                frontSideContent
                    .opacity(isFlipped ? 0 : 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 32)) // Обрезаем контент по краям
            
            // --- ИНДИКАТОР СВАЙПА ---
            if dragOffset.width != 0 && !isFlipped {
                swipeStatusOverlay
            }
        }
        .frame(height: 540) // Чуть выше для воздуха
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8) // Небольшой отступ от краев экрана
        
        // --- АНИМАЦИИ ---
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .offset(x: dragOffset.width, y: dragOffset.height * 0.1)
        .rotationEffect(.degrees(Double(dragOffset.width / 15)))
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isFlipped.toggle()
            }
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in dragOffset = gesture.translation }
                .onEnded { gesture in
                    let threshold: CGFloat = 100
                    if gesture.translation.width > threshold {
                        completeSwipe(direction: 1000, action: onRemove)
                    } else if gesture.translation.width < -threshold {
                        completeSwipe(direction: -1000, action: onReturn)
                    } else {
                        withAnimation(.spring()) { dragOffset = .zero }
                    }
                }
        )
    }
    
    // MARK: - FRONT SIDE (ВОПРОС)
    private var frontSideContent: some View {
        ZStack {
            // 1. Декоративный фон (Водяной знак)
            GeometryReader { geo in
                Text(word.caseType.prefix(3).uppercased()) // Первые 3 буквы падежа (DAT, AKK)
                    .font(.system(size: 150, weight: .black, design: .rounded))
                    .foregroundColor(accentColor.opacity(0.05)) // Очень прозрачный
                    .rotationEffect(.degrees(-20))
                    .position(x: geo.size.width * 0.8, y: geo.size.height * 0.8)
            }
            
            // 2. Основной текст
            VStack(spacing: 20) {
                Spacer()
                
                (Text(word.base) + Text(" ") + Text(word.preposition))
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2) // Ограничиваем двумя строками
                    .minimumScaleFactor(0.6) // Позволяем тексту сжиматься до 60% размера, прежде чем переносить
                    .fixedSize(horizontal: false, vertical: true) // Запрещаем обрезать текст по горизонтали
                
                Text(L10n.Training.Action.tapToFlip)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .textCase(.uppercase)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                
                Spacer()
            }
            .padding()
        }
    }
    
    // MARK: - BACK SIDE (ОТВЕТ)
    private var backSideContent: some View {
        VStack(spacing: 0) {
            // 1. ШАПКА (Теперь она адаптивная!)
            ZStack(alignment: .bottom) {
                // Фон-прямоугольник подстраивается под контент
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [accentColor.opacity(0.2), accentColor.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                VStack(spacing: 8) {
                    // Глагол + Предлог
                    (Text(word.base) + Text(" ") + Text(word.preposition))
                        .font(.system(size: 28, weight: .heavy, design: .rounded)) // Уменьшили с largeTitle до 30 для надежности
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5) // Позволяем сильно сжиматься
                        .padding(.horizontal, 20)
                    
                    // Перевод
                    Text(word.translationWordWithPrep(for: currentLanguage))
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)    // Отступ сверху
                .padding(.bottom, 20) // ОГРОМНЫЙ ОТСТУП СНИЗУ (Чтобы не наплывало на бейдж)
            }
            .fixedSize(horizontal: false, vertical: true) // Важно: заставляет ZStack облегать контент
            
            // 2. БЕЙДЖ ПАДЕЖА
            Text(word.caseType.uppercased())
                .font(.footnote)
                .fontWeight(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(accentColor)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .shadow(color: accentColor.opacity(0.4), radius: 6, y: 4)
                .offset(y: -15) // Наплыв на границу
                .zIndex(1) // Поверх всего

            
            Spacer()
            
            // 3. Блок с примером (в "Пузыре")
            VStack(alignment: .leading, spacing: 12) {
                // Иконка цитаты
                Image(systemName: "quote.opening")
                    .font(.title2)
                    .foregroundColor(accentColor.opacity(0.5))
                
                Text(word.example)
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(word.translation(for: currentLanguage))
                    .font(.subheadline)
                    .italic()
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.primary.opacity(0.03))
            )
            .padding(.horizontal, 20)
            
            Spacer()
            
            // 4. Кнопка звука
            Button {
                Speaker.shared.speak(word.example)
            } label: {
                HStack {
                    Image(systemName: "speaker.wave.2.fill")
                    Text(L10n.Training.Action.listen)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Capsule().fill(Color.blue.opacity(0.1)))
                .foregroundColor(.blue)
            }
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - OVERLAY & HELPERS
    
    private var swipeStatusOverlay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32)
                .fill(dragOffset.width > 0 ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
            
            Image(systemName: dragOffset.width > 0 ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 80))
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(dragOffset.width > 0 ? .green : .red)
                .shadow(radius: 5)
        }
        .opacity(min(abs(dragOffset.width) / 100.0, 1.0))
    }
    
    private func completeSwipe(direction: CGFloat, action: (() -> Void)?) {
        withAnimation(.easeIn(duration: 0.2)) {
            dragOffset.width = direction
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            action?()
        }
    }
}
