import SwiftUI
import AVFoundation

struct GameOver: View {
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0.0
    @State private var isAnimating: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @State private var shouldShowResults: Bool = false
    
    var userId: String
    
    // Add a property for the audio player
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        ZStack {
            Image("mimosa")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                Button(action: {
                    SoundManager.shared.playTransitionSound()
                    shouldShowResults = true
                }) {
                    Text("GAME OVER")
                        .scaledToFit()
                        .foregroundColor(Color.black)
                        .frame(width: 100, height: 100)
                        .scaleEffect(scale)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                }
                .fullScreenCover(isPresented: $shouldShowResults) {
                    ResultadoCompeticion(userId: userId)
                        .onDisappear{
                            presentationMode.wrappedValue.dismiss()
                        }
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            print("GameOver screen appeared")
            
            // Play the game over sound
            playSound()
            
            withAnimation(Animation.easeInOut(duration: 3.0)) {
                self.scale = 3.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(Animation.linear(duration: 1.0)) {
                    self.rotation = 360.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(Animation.easeInOut(duration: 3.0)) {
                        self.scale = 2.0
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                self.isAnimating = true
                            }
                        }
                    }
                }
            }
        }
        .onDisappear {
            print("GameOver screen disappeared")
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func playSound() {
        if let url = Bundle.main.url(forResource: "gameover", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                print("Couldn't load or play the 'gameover.mp3' file: \(error)")
            }
        } else {
            print("The 'gameover.mp3' file was not found in the bundle.")
        }
    }
    
}


struct GameOver_Previews: PreviewProvider {
    static var previews: some View {
        GameOver(userId: "dummyUserId")
    }
}

