import AVFoundation

final class Speaker {
    static let shared = Speaker() // Синглтон для удобства
    private let synthesizer = AVSpeechSynthesizer()
    
    private init() {
        // Настраиваем сессию один раз при создании
        do {
            // .playback позволяет играть звук даже в беззвучном режиме и в фоне
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Ошибка настройки аудио: \(error)")
        }
    }

    func speak(_ text: String) {
        // Настройка аудиосессии, чтобы звук играл даже в беззвучном режиме (опционально)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)

        // Если уже говорит — прерываем
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "de-DE") // Немецкий голос
        utterance.rate = 0.5 // Скорость (0.5 — стандарт, можно медленнее для обучения)
        
        synthesizer.speak(utterance)
    }
}
