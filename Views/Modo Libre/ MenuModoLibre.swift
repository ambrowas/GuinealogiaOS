import SwiftUI
import AVFAudio
import AVFoundation

struct MenuModoLibre: View {
    @State private var playerName: String = ""
    @State private var jugadorGuardado: String = ""
    @State private var jugarModoLibreActive: Bool = false
    @State private var highScore: Int = 0
    @State private var colorIndex: Int = 0
    @Environment(\.presentationMode) var presentationMode
    @State private var scale: CGFloat = 1.0
    @State private var glowColor = Color.blue
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var isShowingMenuPrincipal = false
    @State private var showNoQuestionsLeftAlert = false
    @State private var  dbHelper = QuizDBHelper.shared
    @State private var didPlayMagic = false

    
    
    
    
    
    private let playerNameKey = "PlayerName"
    private let highScoreKey = "HighScore"
    
    init() {
        loadPlayerName()
        loadHighScore()
    }
    
    var body: some View {
        ZStack {
            Image("dosyy")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Image("logotrivial")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 150)
                    .padding(.top, 20)
                    .shadow(color: glowColor.opacity(0.8), radius: 10, x: 0.0, y: 0.0)
                    .onAppear {
                        scale = 1.01
                    }
                    .onReceive(timer) { _ in
                        switch glowColor {
                        case Color.blue:
                            glowColor = .green
                        case Color.green:
                            glowColor = .red
                        case Color.red:
                            glowColor = .white
                        default:
                            glowColor = .blue
                        }
                    }
                    .padding(.bottom, 10)
                
                
                if jugadorGuardado.isEmpty {
                    TextField("INTRODUCE TU NOMBRE", text: $playerName)
                        .foregroundColor(.black)
                        .font(.custom("MarkerFelt-Thin", size: 16))
                        .frame(width: 220, height: 50)
                        .multilineTextAlignment(.center)
                        .background(RoundedRectangle(cornerRadius: 5).strokeBorder(Color.black, lineWidth: 2))
                        .background(RoundedRectangle(cornerRadius: 1).fill(Color.white))
                    
                } else {
                    Text("¡Mbolan \(jugadorGuardado)! ")
                        .foregroundColor(.black)
                        .font(.custom("MarkerFelt-Thin", size: 20))
                        .padding(.horizontal, 20)
                        .padding(.top, 200)
                }
                
                Text("El record actual es de \(highScore) puntos")
                    .foregroundColor(Color.deepBlue)
                    .font(.custom("MarkerFelt-Thin", size: 16))
                    .padding(.horizontal, 20)
                    .padding(.top, -10)
                    .onAppear {
                        
                    }
                    .padding(.top, 0)
                
                
                Button(action: {
                    SoundManager.shared.playTransitionSound()
                    savePlayerName()
                    jugadorGuardado = playerName
                    playerName = ""
                   
                }) {
                    Text(jugadorGuardado.isEmpty ? "GUARDAR" : "CAMBIAR JUGADOR")
                        .font(.custom("MarkerFelt-Thin", size: 16))
                        .foregroundColor(.black)
                        .frame(width: 200, height: 50)
                        .multilineTextAlignment(.center)
                        .background(Color.pastelSilver)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 3)
                        )
                }
                
                Button(action: {
                    print("JUGAR button tapped from MenuModoLibre")
                    SoundManager.shared.playTransitionSound()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        checkForQuestionsBeforePlaying()
                    }
                }) {
                    Text("JUGAR")
                        .font(.custom("MarkerFelt-Thin", size: 16))
                        .foregroundColor(.black)
                        .padding()
                        .frame(width: 300, height: 75)
                        .background(Color.pastelSilver)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 3)
                        )
                }
                
                
                Button(action: {
                    SoundManager.shared.playTransitionSound()
                    isShowingMenuPrincipal = true
                }) {
                    Text("SALIR")
                        .font(.custom("MarkerFelt-Thin", size: 16))
                        .foregroundColor(.black)
                        .padding()
                        .frame(width: 300, height: 75)
                        .background(Color.pastelSilver)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 3)
                        )
                }
                .fullScreenCover(isPresented: $isShowingMenuPrincipal) {
                    MenuPrincipal(player: .constant(nil))
                }
                
                Spacer()
            }
        }
            .fullScreenCover(isPresented: $jugarModoLibreActive) {
                        JugarModoLibre(player: .constant(nil))
                    }
            .alert(isPresented: $showNoQuestionsLeftAlert) {
                        return Alert(
                            title: Text("Felicidades campeon@"),
                            message: Text("Has completado el Modo Libre. Deberías probar el Modo Competición."),
                            dismissButton: .default(Text("OK"), action: {
                                dbHelper.resetShownQuestions()
                                didPlayMagic = false
                               })
                           )
                       }
                       .navigationBarBackButtonHidden(true)
                       .onAppear {
                        
                           loadPlayerName()
                           loadHighScore()
                       }
                       .onChange(of: showNoQuestionsLeftAlert) { newValue in
                           if newValue {
                               SoundManager.shared.playMagic() // 🔊 Play once
                           }
                       }
                   }

    private func checkForQuestionsBeforePlaying() {
        if let unusedQuestions = dbHelper.getRandomQuestions(count: 10), !unusedQuestions.isEmpty {
            print("✅ Starting round with \(unusedQuestions.count) questions.")
            jugarModoLibreActive = true
        } else {
            print("❌ No questions left! Showing alert.")
            showNoQuestionsLeftAlert = true
        }
    }

    private func savePlayerName() {
        UserDefaults.standard.set(playerName, forKey: playerNameKey)
        SoundManager.shared.playMagic()
    }
    
    private func loadPlayerName() {
        if let savedPlayerName = UserDefaults.standard.string(forKey: playerNameKey) {
            jugadorGuardado = savedPlayerName
        }
    }
    
    private func clearPlayerName() {
        playerName = ""
        UserDefaults.standard.removeObject(forKey: playerNameKey)
    }
    
    private func loadHighScore() {
        highScore = UserDefaults.standard.integer(forKey: highScoreKey)
    }
    
    private func getFlashingColor() -> Color {
        let colors: [Color] = [.red, .blue, .green, .white]
        return colors[colorIndex]
    }
    
    private func startFlashing() {
        let flashingColors: [Color] = [.red, .blue, .green, .white]
        
        let flashingAnimation = Animation
            .linear(duration: 0.5)
            .repeatForever(autoreverses: true)
        
        withAnimation(flashingAnimation) {
            colorIndex = 0
        }
        
        for (index, _) in flashingColors.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                withAnimation(flashingAnimation) {
                    colorIndex = index
                }
            }
        }
    }
}

struct MenuModoLibre_Previews: PreviewProvider {
    static var previews: some View {
        MenuModoLibre()
    }
}

