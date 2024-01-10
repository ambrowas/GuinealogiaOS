import SwiftUI
import AVFAudio

struct JugarModoLibre: View {
    @StateObject private var quizState = QuizState()
    @State private var showAlert = false
    @State private var isShowingResultadoView = false
    @Binding var player: AVAudioPlayer?
    @State private static var playerName = ""
    
    
    
    init(player: Binding<AVAudioPlayer?>) {
        _player = player
    }
    
    
    
    var body: some View {
        
        ZStack {
            Image("coolbackground")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 5) {
                HStack {
                    Text("ACIERTOS: \(quizState.score)")
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.top, .leading], 50)
                    
                }
                
                HStack {
                    Text("PUNTUACION: \(quizState.totalScore)")
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .padding(.leading, 21.0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                HStack {
                    Text("PREGUNTA: \(quizState.preguntaCounter)/\(quizState.randomQuestions.count)")
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .padding(.leading, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Text("\(quizState.timeRemaining)")
                        .foregroundColor(quizState.timeRemaining <= 5 ? .red : .black)
                        .fontWeight(.bold)
                        .font(.system(size: 60))
                        .padding(.trailing, 20.0)
                        .shadow(color: .black, radius: 1, x: 1, y: 1)
                }
                .padding(.top, -250)
                
                Text(quizState.isAnswered ? quizState.answerStatusMessage : quizState.currentQuestion.question)
                    .foregroundColor(quizState.questionTextColor)
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.top, -120)
                
                
                VStack(alignment: .leading, spacing: 10) {
                    RadioButton(text: quizState.currentQuestion.option1, selectedOptionIndex: $quizState.selectedOptionIndex, currentQuestion: quizState.currentQuestion, quizState: quizState)
                    RadioButton(text: quizState.currentQuestion.option2, selectedOptionIndex: $quizState.selectedOptionIndex, currentQuestion: quizState.currentQuestion, quizState: quizState)
                    RadioButton(text: quizState.currentQuestion.option3, selectedOptionIndex: $quizState.selectedOptionIndex, currentQuestion: quizState.currentQuestion, quizState: quizState)
                    
                }
                .padding(.bottom, 200)
                
                Button(action: {
                    switch quizState.buttonText {
                    case "CONFIRMAR":
                        quizState.checkAnswer()
                        if quizState.currentQuestionIndex < quizState.randomQuestions.count - 1 {
                            quizState.buttonText = "SIGUIENTE"
                        } else {
                            // This will handle the last question
                            quizState.buttonText = "TERMINAR"
                        }
                    case "SIGUIENTE":
                        if quizState.currentQuestionIndex < quizState.randomQuestions.count - 1 {
                            quizState.showNextQuestion()
                        } else {
                            print("Last question already answered.")
                        }
                    case "TERMINAR":
                        quizState.finishQuiz()
                        isShowingResultadoView = true
                    default:
                        break
                    }
                })
                    {
                    Text(quizState.buttonText)
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(width: 300, height: 75)
                        .background(Color(.white))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 3)
                        )
                }
                .padding(.top, -180)
                .fullScreenCover(isPresented: $isShowingResultadoView) {
                    ResultadoView(aciertos: quizState.score, puntuacion: quizState.totalScore, errores: quizState.mistakes)
                }
                
            }
            .padding(.horizontal, 12)
        }
        .onAppear {
            quizState.startCountdownTimer()
           
            
        }
        .alert(isPresented: $quizState.showAlert) {
            Alert(
                title: Text(quizState.alertMessage),
                message: Text(quizState.displayMessage),
                dismissButton: .default(Text("OK")) {
                    quizState.showAlert = false  // Dismiss the alert
                    quizState.dbHelper.resetShownQuestions()  // Reset shown questions
                    quizState.finishQuiz()                    // Finish the quiz
                }
            )
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("ATENCION"),
                message: Text("Sin miedo, escoge una opción"),
                dismissButton: .default(Text("OK"))
            )
        }
        
    }
    
    
    func confirmAnswerAction() {
        if quizState.selectedOptionIndex == -1 {
            showAlert = true
        } else {
            quizState.checkAnswer()
        
        }
    }
    
    func nextQuestionAction() {
        quizState.showNextQuestion()
        resetForNewQuestion()
    }
    
    func finishQuizAction() {
        SoundManager.shared.playTransitionSound()
        quizState.finishQuiz()
        isShowingResultadoView = true
    }
    
    func resetForNewQuestion() {
        quizState.buttonText = "CONFIRMAR"
        quizState.isAnswered = false
        quizState.selectedOptionIndex = -1
    }
    
    struct JugarModoLibre_Previews: PreviewProvider {
        static var previews: some View {
            JugarModoLibre(player: .constant(nil))
        }
    }
    
    
    struct RadioButton: View {
        var text: String
        @Binding var selectedOptionIndex: Int
        var currentQuestion: QuizQuestion
        @ObservedObject var quizState: QuizState
        @State private var isFlashing = false
        @State private var flashCount = 0
        
        var body: some View {
            Button(action: {
                selectedOptionIndex = optionIndex
            }) {
                Text(text.uppercased())
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 300, height: 75)
                    .background(optionBackground)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 3))
            }
            .opacity(isFlashing ? 0.5 : 1) // Properly chained modifier
            .animation(isFlashing ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : nil, value: isFlashing)  // Properly chained modifier
            .onChange(of: selectedOptionIndex) { _ in
                updateOptionBackground()
            }
            .onAppear {
                updateOptionBackground()
            }
            .onChange(of: isFlashing) { newValue in
                if newValue {
                    startFlashing()
                }
            }
            .onReceive(quizState.$resetFlashingSignal) { resetSignal in
                if resetSignal {
                    resetFlashingState()
                    quizState.resetFlashingSignal = false // Reset the signal to avoid repeated resets
                }
            }
            .onReceive(quizState.$shouldFlashCorrectAnswer) { shouldFlash in
                if shouldFlash && shouldFlashCondition {
                    startFlashing()  // Start the animation if the condition is met
                }
            }
        }
        
        private func startFlashing() {
            guard !isFlashing else { return } // Avoid re-entering while flashing
            isFlashing = true
            flashCount = 0
            
            let flashDuration = 0.5  // The duration of a single fade out/in
            
            withAnimation(Animation.easeInOut(duration: flashDuration).repeatCount(6, autoreverses: true)) { // This will create six animations of half a second each (three flashes)
                self.flashCount = 3 // or any other way you use to decide when to stop blinking
            }
            
            // Wait for the total duration of the flashes before setting isFlashing back to false
            let totalFlashingDuration = flashDuration * 6 // Three flashes, each requiring two half-second animations (fade out and back in)
            DispatchQueue.main.asyncAfter(deadline: .now() + totalFlashingDuration) {
                self.isFlashing = false // Make sure to stop flashing
            }
        }
        
        private var shouldFlashCondition: Bool {
            optionIndex == currentQuestion.correctAnswerIndex && quizState.selectedIncorrectAnswer
        }
        
        func resetFlashingState() {
            isFlashing = false
            flashCount = 0
        }
        
        
        private var optionIndex: Int {
            switch text {
            case currentQuestion.option1: return 0
            case currentQuestion.option2: return 1
            case currentQuestion.option3: return 2
            default: return -1
            }
        }
        
        @State private var optionBackground: Color = Color(hue: 0.663, saturation: 0.811, brightness: 0.631)
        
        private func updateOptionBackground() {
            if optionIndex == selectedOptionIndex {
                optionBackground = Color(hue: 0.315, saturation: 0.953, brightness: 0.335)
            } else {
                optionBackground = Color(hue: 0.663, saturation: 0.811, brightness: 0.631)
            }
        }
    }
}
