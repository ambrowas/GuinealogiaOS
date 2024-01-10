import SwiftUI
import AVFoundation

struct Proverbio: Codable, Identifiable {
    let id = UUID()
    let numero: Int
    let idioma: String
    let texto: String
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

    private var audioURL: URL? {
        Bundle.main.url(forResource: "intro", withExtension: "mp3")
    }
#if DEBUG
var isPreview: Bool {
    ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}
#endif


    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 20) {
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
                    Text(proverbioTexto)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                if showTextView {
                    Text("PULSA AQUI PARA CONTINUAR")
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .padding()
                        .onTapGesture {
                            SoundManager.shared.playTransitionSound()
                            shouldNavigate = true
                        }
                }
            }
            .offset(y: -50)
        }
        .fullScreenCover(isPresented: $shouldNavigate) {
            MenuPrincipal(player: .constant(nil))
        }
        .onAppear {
            if isPreview { return } 
            startAudio()
            runAnimations()
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
                        proverbioTexto = proverbios.randomElement()?.texto ?? ""

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
        Group {
            Text("Preview Placeholder")
                .font(.title)
                .foregroundColor(.gray)
        }
    }
}
