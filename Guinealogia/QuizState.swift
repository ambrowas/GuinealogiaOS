import SwiftUI
import Combine
import AVFoundation

class QuizState: ObservableObject {
    let dbHelper = QuizDBHelper()
    var randomQuestions: [QuizQuestion]
    private var rightSoundEffect: AVAudioPlayer?
    private var wrongSoundEffect: AVAudioPlayer?
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var currentQuestionIndex = 0
    @Published var selectedOptionIndex = -1
    @Published var timeRemaining = 15
    @Published var isAnswered = false
    @Published var score = 0
    @Published var totalScore = 0
    @Published var preguntaCounter = 1
    @Published var isShowingResultadoView = false
    @Published var buttonText = "CONFIRMAR"
    @Published var displayMessage = ""
    @Published var isOptionSelected = false
    private var timer: Timer?
    @Published var mistakes = 0
    @Binding var player: AVAudioPlayer?
    
    init(player: Binding<AVAudioPlayer?>) {
        self._player = player
        randomQuestions = dbHelper.getRandomQuestions(count: 10)
        rightSoundEffect = loadSoundEffect(named: "right")
        wrongSoundEffect = loadSoundEffect(named: "notright")
    }

    lazy var currentQuestion: QuizQuestion = {
        // Reset text color to black when assigning a new question
        var question = randomQuestions[currentQuestionIndex]
        question.textColor = .black
        return question
    }()
    init() {
        self.randomQuestions = dbHelper.getRandomQuestions(count: 10)
        self._player = Binding<AVAudioPlayer?>(get: { nil }, set: { _ in })
        
        loadSoundEffects(player: $player)
    }

    func startCountdownTimer() {
        timer?.invalidate() // Invalidate any existing timer
        
        // Check if there are questions left
        if currentQuestionIndex < randomQuestions.count {
            timeRemaining = 15
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.timer?.invalidate()
                    self.timer = nil
                    self.checkAnswer()
                }
            }
        }
    }

        
        internal func checkAnswer() {
            if !isAnswered {
                isAnswered = true
                timer?.invalidate()
                timer = nil
                
                let selectedOption = selectedOptionIndex + 1
                let correctOption = currentQuestion.answerNr
                
                if selectedOption == correctOption {
                    score += 1
                    totalScore += 500
                    
                    // Play right sound effect
                    rightSoundEffect?.play()
                    
                    // Set currentQuestion text to "RESPUESTA CORRECTA"
                                currentQuestion.question = "RESPUESTA CORRECTA"
                                currentQuestion.textColor = Color(hue: 0.315, saturation: 0.953, brightness: 0.335)
                            } else {
                                mistakes += 1
                                wrongSoundEffect?.play()

                                // Set currentQuestion text to "RESPUESTA INCORRECTA"
                                currentQuestion.question = "RESPUESTA INCORRECTA"
                                currentQuestion.textColor = Color(hue: 1.0, saturation: 0.984, brightness: 0.699)
                            }

                
                if selectedOptionIndex == -1 {
                    // No option selected
                    showAlert = true
                    alertMessage = "Sin miedo, elige una opción"
                    displayMessage = "Sin miedo, elige una opción"
                    isOptionSelected = false
                } else {
                    // Option selected
                    isOptionSelected = true
                    
                    if preguntaCounter <= randomQuestions.count {
                        buttonText = "SIGUIENTE"
                    } else {
                        finishQuiz()
                    }
                }
            }
        }
        
    func showNextQuestion() {
        if !isAnswered {
            showAlertIfNoAnswerSelected()
        } else {
            currentQuestionIndex += 1
            if currentQuestionIndex < randomQuestions.count {
                buttonText = "CONFIRMAR"
                isAnswered = false
                selectedOptionIndex = -1
                currentQuestion = randomQuestions[currentQuestionIndex]
                preguntaCounter += 1
                startCountdownTimer()
                timeRemaining = 15
            } else {
                finishQuiz()
            }
        }
    }

        
        private func showAlertIfNoAnswerSelected() {
            if selectedOptionIndex == -1 {
                showAlert = true
                alertMessage = "Sin miedo, elige una opción"
                displayMessage = "Sin miedo, elige una opción"
                isOptionSelected = false
            }
        }
        
    func finishQuiz() {
        let aciertos = score
        let puntuacion = totalScore
        let errores = mistakes
        
        // Save the aciertos and puntuacion to UserDefaults
        UserDefaults.standard.set(aciertos, forKey: "aciertos")
        UserDefaults.standard.set(puntuacion, forKey: "puntuacion")
        UserDefaults.standard.set(errores, forKey: "errores")
        
        // Navigate to the Resultado view
        let resultadoView = ResultadoView(aciertos: aciertos, puntuacion: puntuacion, errores: errores)

        // Use NavigationLink to navigate to the ResultadoView class
        NavigationLink(destination: resultadoView) {
            EmptyView()
        }
    }
        
    private func loadSoundEffects(player: Binding<AVAudioPlayer?>) {
            rightSoundEffect = loadSoundEffect(named: "right")
            wrongSoundEffect = loadSoundEffect(named: "notright")
            self.player = player.wrappedValue
        }
        
    private func loadSoundEffect(named name: String) -> AVAudioPlayer? {
           if let path = Bundle.main.path(forResource: name, ofType: "wav") {
               let url = URL(fileURLWithPath: path)
               do {
                   let soundEffect = try AVAudioPlayer(contentsOf: url)
                   soundEffect.prepareToPlay()
                   return soundEffect
               } catch {
                   print("Error loading sound effect: \(error.localizedDescription)")
               }
           }
           return nil
       }
   }

