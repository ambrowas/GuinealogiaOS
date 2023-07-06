import SwiftUI
import AVFAudio

struct MenuModoLibre: View {
    @State private var playerName: String = ""
    @State private var jugadorGuardado: String = ""
    @State private var jugarModoLibreActive: Bool = false
    @State private var highScore: Int = 0
    @State private var colorIndex: Int = 0
    @State private var showMenuPrincipal = false
    
    private let playerNameKey = "PlayerName"
    private let highScoreKey = "HighScore"
    
    init() {
        loadPlayerName()
        loadHighScore()
    }
    
    var body: some View {
        ZStack {
            Image("coolbackground")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Image("logotrivial")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.top, 15)
                    .frame(width: 200, height: 150)
                
                if jugadorGuardado.isEmpty {
                    TextField("INTRODUCE TU NOMBRE", text: $playerName)
                        .foregroundColor(.black)
                        .font(.system(size: 10))
                        .frame(width: 200, height: 50)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 20)
                } else {
                    Text("HOLA \(jugadorGuardado)")
                        .foregroundColor(.black)
                        .font(.headline)
                        .padding(.horizontal, 20)
                        .padding(.top, 80)
                }
                
                Text("El record actual es de \(highScore) puntos")
                    .foregroundColor(getFlashingColor())
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.top, -10)
                    .onAppear {
                        startFlashing()
                    }
                
                Button(action: {
                    savePlayerName()
                    jugadorGuardado = playerName
                    playerName = ""
                }) {
                    Text(jugadorGuardado.isEmpty ? "GUARDAR" : "CAMBIAR JUGADOR")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .multilineTextAlignment(.center)
                        .background(Color(hue: 0.664, saturation: 0.935, brightness: 0.604))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 3)
                        )
                }
                
                Button(action: {
                    jugarModoLibreActive = true
                }) {
                    Text("JUGAR")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 75)
                        .background(Color(hue: 0.315, saturation: 0.953, brightness: 0.335))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 3)
                        )
                }
                .onTapGesture {
                    jugarModoLibreActive.toggle()
                }
                .sheet(isPresented: $jugarModoLibreActive, content: {
                    JugarModoLibre(player: .constant(nil))
                })
                
                Button(action: {
                    showMenuPrincipal = true
                }) {
                    Text("SALIR")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 75)
                        .background(Color(hue: 1.0, saturation: 0.984, brightness: 0.699))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 3)
                        )
                }
                .sheet(isPresented: $showMenuPrincipal) {
                    MenuPrincipal(player: .constant(nil))
                }


                
                Spacer()
            }
        }
        .onAppear {
            loadPlayerName()
            loadHighScore()
        }
    }
    
    private func savePlayerName() {
        UserDefaults.standard.set(playerName, forKey: playerNameKey)
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

