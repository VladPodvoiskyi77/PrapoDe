import AVFoundation

final class Speaker {
    static let shared = Speaker()
    private let synthesizer = AVSpeechSynthesizer()
    
    private init() {
        do {
            // .playback позволяет играть звук даже в беззвучном режиме и в фоне
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Ошибка настройки аудио: \(error)")
        }
    }

    func speak(_ text: String) {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "de-DE")
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
}
