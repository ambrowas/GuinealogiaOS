import AVFoundation
class SoundManager {
    static let shared = SoundManager()
    private var player: AVAudioPlayer?

    private func playSound(named name: String, withExtension ext: String = "mp3") {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("Sound file \(name).\(ext) not found")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("Failed to play sound \(name): \(error)")
        }
    }

    // All your sounds
    func playCountdown() { playSound(named: "countdown") }
    func playDrumroll() { playSound(named: "drumroll") }
    func playError() { playSound(named: "error") }
    func playGameover() { playSound(named: "game-over") }
    
    
    func playNotright() { playSound(named: "notright") }
    func playRight() { playSound(named: "right") }
    func playNo() { playSound(named: "no") }


    // WAV
    func playIntro() { playSound(named: "intro", withExtension: "wav") }
    func playTransitionSound() { playSound(named: "swoosh", withExtension: "wav") }
    func playMagic() { playSound(named: "magic") }
    func playPick() { playSound(named: "pick") }

    func playLow1() { playSound(named: "low1") }
    func playLow2() { playSound(named: "low2") }
    func playLow3() { playSound(named: "low3") }
    func playLow4() { playSound(named: "low4") }

    func playMedium1() { playSound(named: "medium1") }
    func playMedium2() { playSound(named: "medium2") }
    func playMedium3() { playSound(named: "medium3") }
    func playMedium4() { playSound(named: "medium4") }
    
    func playHigh1() { playSound(named: "high1") }
    func playHigh2() { playSound(named: "high2") }
    func playHigh3() { playSound(named: "high3") }
    func playHigh4() { playSound(named: "high4") }

 
   

    // MARK: - Random Tier Sounds
    func playRandomLow() {
        let lowOptions = [playLow1, playLow2, playLow3, playLow4]
        lowOptions.randomElement()?()
    }

    func playRandomMedium() {
        let mediumOptions = [playMedium1, playMedium2, playMedium3, playMedium4]
        mediumOptions.randomElement()?()
    }

    func playRandomHigh() {
        let highOptions = [playHigh1, playHigh2, playHigh3, playHigh4]
        highOptions.randomElement()?()
    }
}
