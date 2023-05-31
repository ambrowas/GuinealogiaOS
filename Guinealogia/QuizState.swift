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
    
    lazy var currentQuestion: QuizQuestion = {
        // Reset text color to black when assigning a new question
        var question = randomQuestions[currentQuestionIndex]
        question.textColor = .black
        return question
    }()
    
    init() {
        randomQuestions = dbHelper.getRandomQuestions(count: 10)
        rightSoundEffect = loadSoundEffect(named: "right")
        wrongSoundEffect = loadSoundEffect(named: "notright")
    }
        
        func startCountdownTimer() {
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
                    currentQuestion.textColor = Color.green
                } else {
                    // Play wrong sound effect
                    wrongSoundEffect?.play()
                    
                    // Set currentQuestion text to "RESPUESTA INCORRECTA"
                    currentQuestion.question = "RESPUESTA INCORRECTA"
                    currentQuestion.textColor = Color.red
                }
                
                preguntaCounter += 1
                
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
                currentQuestion = randomQuestions[currentQuestionIndex] // Set the currentQuestion to the next question from the database
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
        
        private func finishQuiz() {
            let aciertos = score
            let puntuacion = totalScore
            
            // Save the aciertos and puntuacion to UserDefaults
            UserDefaults.standard.set(aciertos, forKey: "aciertos")
            UserDefaults.standard.set(puntuacion, forKey: "puntuacion")
            
            // Navigate to the Resultado view
            // Assuming you're using NavigationLink or sheet for navigation
            isShowingResultadoView = true
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

