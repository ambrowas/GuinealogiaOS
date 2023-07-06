import SwiftUI
import AVFoundation

struct GameOver: View {
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0.0
    @State private var player: AVAudioPlayer?
    @State private var isAnimating: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @Binding var shouldNavigateToResultado: Bool

    var body: some View {
        NavigationView {
            ZStack {
                Image("mimosa")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()

                    NavigationLink(destination: ResultadoCompeticion(userId: "defaultUserId")) {
                        Text("GAME OVER")
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .scaleEffect(scale)
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                    }
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }


                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
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

            if let url = Bundle.main.url(forResource: "gameover", withExtension: "mp3") {
                do {
                    self.player = try AVAudioPlayer(contentsOf: url)
                    self.player?.play()
                } catch {
                    print("Could not create AVAudioPlayer: \(error)")
                }
            } else {
                print("Could not find URL for audio file")
            }
        }
    }
}

struct GameOver_Previews: PreviewProvider {
    static var previews: some View {
        GameOver(shouldNavigateToResultado: .constant(false)) // Add the missing parameter
            .previewDevice("iPhone 14")
    }
}
