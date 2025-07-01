import SwiftUI
import AVFoundation

struct Proverbio: Codable, Identifiable {
    let id = UUID()
    let numero: Int
    let idioma: String
    let texto: String
    let traduccion: String?
}

struct ProverbiosWrapper: Codable {
    let proverbios: [Proverbio]
}

struct FlashView: View {
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0.0
    @State private var player: AVAudioPlayer?
    @State private var isAnimating = false
    @State private var shouldNavigate = false
    @State private var showTextView = false
    @State private var proverbioTexto = ""
    @State private var proverbioTraduccion = ""

    private var audioURL: URL? {
        Bundle.main.url(forResource: "intro", withExtension: "wav")
    }

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 50) {
                Image("logotrivial")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation))
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .onTapGesture {
                        SoundManager.shared.playTransitionSound()
                        shouldNavigate = true
                    }

                if !proverbioTexto.isEmpty {
                    VStack(spacing: 6) {
                        Text("“\(proverbioTexto)”")
                            .font(.custom("TheBomb", size: 12))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        if !proverbioTraduccion.isEmpty {
                            Text("→ \(proverbioTraduccion)")
                                .font(.custom("TheBomb", size: 12))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                }

                if showTextView {
                    Text("PULSA AQUI PARA CONTINUAR")
                        .font(.custom("MarkerFelt-Thin", size: 16))
                        .foregroundColor(.black)
                        .padding()
                        .onTapGesture {
                            SoundManager.shared.playTransitionSound()
                            fadeOutAudioAndNavigate()
                        }
                }
            }
            .offset(y: -100)
        }
        .fullScreenCover(isPresented: $shouldNavigate) {
            MenuPrincipal(player: .constant(nil))
        }
        .onAppear {
            startAudio()
            runAnimations()
        }
    }
    
    private func fadeOutAudioAndNavigate() {
        player?.setVolume(0, fadeDuration: 1.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            player?.stop()
            player = nil  // 🔄 Reset the player
            shouldNavigate = true
        }
    }

    private func loadProverbios() -> [Proverbio] {
        guard let url = Bundle.main.url(forResource: "proverbioscompletos", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(ProverbiosWrapper.self, from: data) else {
            return []
        }
        return decoded.proverbios
    }

    private func startAudio() {
        DispatchQueue.global().async {
            if let url = audioURL {
                do {
                    player = try AVAudioPlayer(contentsOf: url)
                    player?.prepareToPlay()
                    DispatchQueue.main.async {
                        player?.play()
                    }
                } catch {
                    print("Failed to load audio: \(error)")
                }
            }
        }
    }

    private func runAnimations() {
        withAnimation(.easeInOut(duration: 3.0)) {
            scale = 3.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.linear(duration: 1.0)) {
                rotation = 360.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 3.0)) {
                    scale = 2.0

                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                            isAnimating = true
                        }

                        // Show proverb
                        let proverbios = loadProverbios()
                        if let random = proverbios.randomElement() {
                            proverbioTexto = random.texto
                            proverbioTraduccion = random.traduccion ?? ""
                        }

                        // Show "Pulsa aquí" after 0.5s
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation {
                                showTextView = true
                            }
                        }
                    }
                }
            }
        }
    }
}

struct FlashView_Previews: PreviewProvider {
    static var previews: some View {
        FlashView()
    }
}
