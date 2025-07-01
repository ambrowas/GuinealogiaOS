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
    @State private var showMenuModoLibre = false
    @State private var playerName: String = ""
    @State private var highScore: Int = 0
    @State private var isNewHighScore: Bool = false
    @State private var showAlert = false
    @State private var isAnimating: Bool = false
    @State private var dbHelper = QuizDBHelper.shared
    @State private var navigateToMenuPrincipal = false
    @State private var jugarModoLibreActive: Bool = false
    @State private var showNoQuestionsLeftAlert = false // Initialize the state variable
    @State private var showCustomPopup = false

    

   
    
    var body: some View {
        ZStack {
            Image("dosyy")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // 🏆 Trophy image with animation
                // 🏆 Trophy image with fade-in and pulse animation
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.top, -100.0)
                    .frame(width: 300, height: 250)
                    .opacity(isShowingImage ? 1 : 0)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .onAppear {
                        withAnimation(.easeIn(duration: 2.0)) {
                            isShowingImage = true
                        }
                        withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                            isAnimating = true
                        }
                    }
                Text(textFieldText)
                    .foregroundColor(.black)
                    .font(.custom("MarkerFelt-Thin", size: 18))
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                    .multilineTextAlignment(.center)

                StatTable(stats: [
                    ("PREGUNTAS ACERTADAS", "\(aciertos)", Color(hue: 0.617, saturation: 0.831, brightness: 0.591)),
                    ("ERRORES COMETIDOS", "\(errores)", Color(hue: 0.994, saturation: 0.963, brightness: 0.695)),
                    ("PUNTUACIÓN OBTENIDA", "\(puntuacion)", Color(hue: 0.404, saturation: 0.934, brightness: 0.334))
                ])
                HStack {
                    Button(action: {
                        SoundManager.shared.playTransitionSound()
                        print("JUGAR button tapped from Resultado")
                        checkForQuestionsBeforePlaying()
                        
                    }) {
                        Text("JUGAR")
                            .font(.custom("MarkerFelt-Thin", size: 18))
                            .foregroundColor(.black)
                            .padding()
                            .frame(width: 180, height: 60)
                            .background(Color.pastelSilver)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.black, lineWidth: 3)
                            )
                    }
                    .padding(.top, 30)
                    .fullScreenCover(isPresented: $jugarModoLibreActive) {
                        JugarModoLibre(player: .constant(nil))
                    }
                    
                    Button(action: {
                        SoundManager.shared.playTransitionSound()
                        showMenuModoLibre = true
                        
                    }) {
                        Text("SALIR")
                            .font(.custom("MarkerFelt-Thin", size: 18))
                            .foregroundColor(.black)
                            .padding()
                            .frame(width: 180, height: 60)
                            .background(Color.pastelSilver)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.black, lineWidth: 3)
                            )
                    }
                    .padding(.top, 30)
                    .fullScreenCover(isPresented: $showMenuModoLibre) {
                        MenuModoLibre()
                    }
                    .alert(isPresented: $showNoQuestionsLeftAlert) {
                        // Asegurarte que suene solo una vez:
                        DispatchQueue.main.async {
                            SoundManager.shared.playMagic()
                        }

                        return Alert(
                            title: Text("Atención"),
                            message: Text("Felicidades campeón@, has completado el Modo Libre. Deberías probar el Modo Competición."),
                            dismissButton: .default(Text("OK"), action: {
                                print("Alert dismiss button tapped.") // Debugging print
                                dbHelper.resetShownQuestions()
                            })
                        )
                    }
                    
                    
                }
            }
        }
        .onAppear {
            print("ResultadoView appeared")
            handleAciertos()
            checkHighScore()
            let unusedQuestionsCount = dbHelper.getNumberOfUnusedQuestions()
                       print("Number of unused questions: \(unusedQuestionsCount)")
            
        }
        .navigationBarHidden(true)
        
    }
    
    private func checkForQuestionsBeforePlaying() {
        if let unusedQuestions = dbHelper.getRandomQuestions(count: 10), !unusedQuestions.isEmpty {
            jugarModoLibreActive = true
        } else {
            SoundManager.shared.playMagic() // 🔊 Play the sound ONCE here
            showNoQuestionsLeftAlert = true
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
            imageName = "guinealogoexperto"
            textFieldText = ResultSentences.highPerformance.randomElement() ?? "¡Excelente!"
            SoundManager.shared.playRandomHigh()

        } else if aciertos >= 5 {
            imageName = "guinealogo_intermedio"
            textFieldText = ResultSentences.mediumPerformance.randomElement() ?? "¡Buen trabajo!"
            SoundManager.shared.playRandomMedium()

        } else {
            imageName = "guinealogo_mediocre"
            textFieldText = ResultSentences.lowPerformance.randomElement() ?? "¡Inténtalo de nuevo!"
            SoundManager.shared.playRandomLow()
        }
    }
  
    
    struct StatTable: View {
        let stats: [(label: String, value: String, color: Color)]

        var body: some View {
            VStack(spacing: 0) {
                ForEach(0..<stats.count, id: \.self) { index in
                    HStack {
                        Text(stats[index].label)
                            .font(.custom("MarkerFelt-Thin", size: 16))
                            .foregroundColor(stats[index].color)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(stats[index].value)
                            .font(.custom("MarkerFelt-Thin", size: 20))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 10)
                    .background(Color.pastelSilver)
                    
                    if index < stats.count - 1 {
                        Divider().background(Color.black)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 2)
            )
            .padding(.horizontal, 20)
        }
    }
    
    struct ResultadoView_Previews: PreviewProvider {
        static var previews: some View {
            ResultadoView(aciertos: 8, puntuacion: 4000, errores: 2)
        }
    }
    
}
