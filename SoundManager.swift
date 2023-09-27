import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    
    private init() { }
    
    func playTransitionSound() {
        // Get the URL of the sound file in the app bundle
        if let soundURL = Bundle.main.url(forResource: "swoosh", withExtension: "wav") {
            do {
                // Initialize and play the audio player
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.play()
            } catch let error as NSError {
                // Handle and print the error
                print("Failed to play transition sound: \(error.localizedDescription)")
            }
        } else {
            print("Sound file 'swoosh.wav' not found in the app bundle.")
        }
    }
}
