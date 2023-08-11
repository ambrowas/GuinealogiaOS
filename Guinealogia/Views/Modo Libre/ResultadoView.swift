import SwiftUI
import AVFoundation

struct ResultadoView: View {
    let aciertos: Int
    let puntuacion: Int
    let errores: Int
    @State private var imageName = ""
    @State private var textFieldText = ""
    @State private var isShowingImage = false
    @State private var isTextVisible = false
    @State private var player: AVAudioPlayer?
    @Environment(\.presentationMode) var presentationMode
    @State private var showJugarModoLibre = false
    @State private var showMenuPrincipal = false
    @State private var playerName: String = ""
    @State private var highScore: Int = 0
    @State private var isNewHighScore: Bool = false
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("coolbackground")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.top, -100.0)
                        .padding(.top)
                        .frame(width: 300, height: 250)
                        .opacity(isShowingImage ? 1 : 0)
                        .animation(.easeIn(duration: 2.0))
                        .onAppear {
                            withAnimation {
                                isShowingImage = true
                            }
                        }
                    
                    Text(textFieldText)
                        .foregroundColor(.black)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .padding(.top, -50)
                        .opacity(isTextVisible ? 1 : 0)
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                self.isTextVisible.toggle()
                            }
                        }
                    
                    TextField("", text: $playerName)
                        .font(.title)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .multilineTextAlignment(.center)
                        .frame(width: 300, height: 65)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 3)
                        )
                        .overlay(
                            Text("PREGUNTAS ACERTADAS: \(aciertos)")
                                .font(.headline)
                                .foregroundColor(Color(hue: 0.617, saturation: 0.831, brightness: 0.591))
                                .padding(.horizontal)
                        )
                    
                    TextField("", text: .constant(""))
                        .font(.title)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .multilineTextAlignment(.center)
                        .frame(width: 300, height: 65)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 3)
                        )
                        .overlay(
                            Text("ERRORES COMETIDOS: \(errores)")
                                .font(.headline)
                                .foregroundColor(Color(hue: 0.994, saturation: 0.963, brightness: 0.695))
                                .padding(.horizontal)
                        )
                    
                    TextField("", text: .constant(""))
                        .font(.title)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .multilineTextAlignment(.center)
                        .frame(width: 300, height: 65)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 3)
                        )
                        .overlay(
                            Text("PUNTUACION OBTENIDA: \(puntuacion)")
                                .font(.headline)
                                .foregroundColor(Color(hue: 0.404, saturation: 0.934, brightness: 0.334))
                                .padding(.horizontal)
                        )
                    
                    HStack {
                        Button(action: {
                            showJugarModoLibre = true
                        }) {
                            Text("JUGAR")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 180, height: 60)
                                .background(Color(hue: 0.69, saturation: 0.89, brightness: 0.706))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.black, lineWidth: 3)
                                )
                        }
                        .padding(.top, 30)
                        .fullScreenCover(isPresented: $showJugarModoLibre) {
                            JugarModoLibre(player: .constant(nil))
                        }
                        
                        Button(action: {
                            showMenuPrincipal = true
                        }) {
                            Text("SALIR")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 180, height: 60)
                                .background(Color(hue: 1.0, saturation: 0.984, brightness: 0.699))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.black, lineWidth: 3)
                                )
                        }
                        .padding(.top, 30)
                        .sheet(isPresented: $showMenuPrincipal) {
                            MenuPrincipal(player: .constant(nil))
                        }
                    }
                }
            }
            .onAppear {
                handleAciertos()
                checkHighScore()
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Nuevo Record"),
                    message: Text("¡Felicidades! Has establecido un nuevo record."),
                    dismissButton: .default(Text("Ok"))
                )
            }
        }
    }
    
    private func checkHighScore() {
        let userDefaults = UserDefaults.standard
        let previousHighScore = userDefaults.integer(forKey: "HighScore")
        
        if puntuacion > previousHighScore {
            highScore = puntuacion
            isNewHighScore = true
            userDefaults.set(highScore, forKey: "HighScore")
            showAlert = true
        } else {
            highScore = previousHighScore
            isNewHighScore = false
        }
    }

    
    private func handleAciertos() {
        if aciertos >= 9 {
            if let hallelujahSoundURL = Bundle.main.url(forResource: "hallelujah", withExtension: "mp3") {
                do {
                    self.player = try AVAudioPlayer(contentsOf: hallelujahSoundURL)
                    self.player?.play()
                } catch {
                    print("Could not create AVAudioPlayer: \(error)")
                }
            } else {
                print("Could not find URL for audio file")
            }
            
            imageName = "guinealogoexperto"
            textFieldText = "NECESITAMOS MÁS GUINEANOS COMO TÚ"
        } else if aciertos >= 5 && aciertos <= 8 {
            if let mixkitSoundURL = Bundle.main.url(forResource: "mixkit", withExtension: "wav") {
                do {
                    self.player = try AVAudioPlayer(contentsOf: mixkitSoundURL)
                    self.player?.play()
                } catch {
                    print("Could not create AVAudioPlayer: \(error)")
                }
            } else {
                print("Could not find URL for audio file")
            }
            
            imageName = "guinealogo_intermedio"
            textFieldText = "NO ESTÁ MAL, PERO PODRÍAS HACERLO MEJOR"
        } else {
            if let noluckSoundURL = Bundle.main.url(forResource: "noluck", withExtension: "mp3") {
                do {
                    self.player = try AVAudioPlayer(contentsOf: noluckSoundURL)
                    self.player?.play()
                } catch {
                    print("Could not create AVAudioPlayer: \(error)")
                }
            } else {
                print("Could not find URL for audio file")
            }
            
            imageName = "guinealogo_mediocre"
            textFieldText = "POR GENTE COMO TÚ GUINEA NO AVANZA"
        }
    }
}

struct ResultadoView_Previews: PreviewProvider {
    static var previews: some View {
        ResultadoView(aciertos: 8, puntuacion: 4000, errores: 2)
    }
}

