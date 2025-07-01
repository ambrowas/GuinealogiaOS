import SwiftUI
import AVFAudio

struct JugarModoLibre: View {
    @StateObject private var quizState = QuizState()
    @State private var showAlert = false
    @State private var isShowingResultadoView = false
    @Binding var player: AVAudioPlayer?
    @State private static var playerName = ""
    @State private var explicacion: String = ""
    @State private var animateScale = false
    
    
    
    init(player: Binding<AVAudioPlayer?>) {
        _player = player
    }
    
    var body: some View {
        
        ZStack {
            Image("dosyy")
                .resizable()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Score and question number
                VStack(alignment: .leading, spacing: 5) {
                    Text("ACIERTOS: \(quizState.score)")
                    Text("PUNTUACION: \(quizState.totalScore)")
                    Text("PREGUNTA: \(quizState.preguntaCounter)/\(quizState.randomQuestions.count)")
                }
                .foregroundColor(.black)
                .font(.custom("MarkerFelt-Thin", size: 18))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 40)

                // Timer
                HStack {
                    Spacer()
                    Text("\(quizState.timeRemaining)")
                        .foregroundColor(quizState.timeRemaining <= 5 ? .darkRed : .black)
                        .font(.custom("MarkerFelt-Thin", size: 50))
                        .shadow(radius: 1)
                        .padding(.trailing, 20)
                }

                // Question or explanation (in the same fixed location)
                if quizState.isAnswered {
                    VStack(spacing: 10) {
                        Text(quizState.answerStatusMessage) // RESPUESTA CORRECTA / INCORRECTA
                            .font(.custom("MarkerFelt-Thin", size: 20))
                            .foregroundColor(quizState.questionTextColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)

                        Text(quizState.currentQuestion.explicacion ?? "Sin explicación disponible.")
                            .font(.custom("MarkerFelt-Thin", size: 18))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                } else {
                    Text(quizState.currentQuestion.question)
                        .foregroundColor(.black)
                        .font(.custom("MarkerFelt-Thin", size: 18))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                }

                // Options only if not answered
                if !quizState.isAnswered {
                    VStack(spacing: 10) {
                        RadioButton(text: quizState.currentQuestion.option1, selectedOptionIndex: $quizState.selectedOptionIndex, currentQuestion: quizState.currentQuestion, quizState: quizState)
                        RadioButton(text: quizState.currentQuestion.option2, selectedOptionIndex: $quizState.selectedOptionIndex, currentQuestion: quizState.currentQuestion, quizState: quizState)
                        RadioButton(text: quizState.currentQuestion.option3, selectedOptionIndex: $quizState.selectedOptionIndex, currentQuestion: quizState.currentQuestion, quizState: quizState)
                    }
                }

                // Main action button
                Button(action: {
                    switch quizState.buttonText {
                        
                    case "CONFIRMAR":
                        if quizState.selectedOptionIndex == -1 {
                            SoundManager.shared.playError()
                            showAlert = true  // show the "Sin miedo..." alert
                            return
                        }
                        quizState.StopCountdownSound()
                        quizState.checkAnswer()
                        if quizState.currentQuestionIndex < quizState.randomQuestions.count - 1 {
                            quizState.buttonText = "SIGUIENTE"
                        } else {
                            quizState.buttonText = "TERMINAR"
                        }

                    case "SIGUIENTE":
                        SoundManager.shared.playTransitionSound()
                        if quizState.currentQuestionIndex < quizState.randomQuestions.count - 1 {
                            quizState.showNextQuestion()
                        }

                    case "TERMINAR":
                        quizState.finishQuiz()
                        isShowingResultadoView = true

                    default:
                        break
                    }
                }) {
                    Text(quizState.buttonText)
                        .font(.custom("MarkerFelt-Thin", size: 18))
                        .foregroundColor(.black)
                        .frame(width: 300, height: 75)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 3))
                }
                .padding(.top, 10)
                .fullScreenCover(isPresented: $isShowingResultadoView) {
                    ResultadoView(aciertos: quizState.score, puntuacion: quizState.totalScore, errores: quizState.mistakes)
                }

                Spacer()
            }
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
        @State private var optionBackground: Color = .pastelSilver
        @State private var animateScale = false

        var body: some View {
            Button(action: {
                selectedOptionIndex = optionIndex
                SoundManager.shared.playPick()
                updateOptionBackground()
                triggerBounceAnimation()
            }) {
                Text(text.uppercased())
                    .font(.custom("MarkerFelt-Thin", size: 18))
                    .foregroundColor(optionIndex == selectedOptionIndex ? .deepBlue : .black)
                    .padding()
                    .frame(width: 300, height: 75)
                    .background(optionBackground)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 3)
                    )
                    .scaleEffect(optionIndex == selectedOptionIndex && animateScale ? 1.08 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: animateScale)
            }
            .opacity(isFlashing ? 0.5 : 1)
            .animation(isFlashing ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : nil, value: isFlashing)
            .onAppear {
                updateOptionBackground()
            }
            .onChange(of: selectedOptionIndex) { _ in
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
                    quizState.resetFlashingSignal = false
                }
            }
            .onReceive(quizState.$shouldFlashCorrectAnswer) { shouldFlash in
                if shouldFlash && shouldFlashCondition {
                    startFlashing()
                }
            }
        }

        private func triggerBounceAnimation() {
            animateScale = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                animateScale = false
            }
        }

        private func startFlashing() {
            guard !isFlashing else { return }
            isFlashing = true
            flashCount = 0
            let flashDuration = 0.5
            withAnimation(Animation.easeInOut(duration: flashDuration).repeatCount(6, autoreverses: true)) {
                self.flashCount = 3
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + flashDuration * 6) {
                self.isFlashing = false
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

        private func updateOptionBackground() {
            optionBackground = (optionIndex == selectedOptionIndex) ? .white : .pastelSilver
        }
    }
}
