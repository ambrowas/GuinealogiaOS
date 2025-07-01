import SwiftUI
import Combine
import AVFoundation

class QuizState: ObservableObject {
    let  dbHelper = QuizDBHelper.shared
    var randomQuestions: [QuizQuestion]
    private var rightSoundEffect: AVAudioPlayer?
    private var wrongSoundEffect: AVAudioPlayer?
    private var countdownSound: AVAudioPlayer?
    private var timer: Timer? // Declare timer here
    @Published var showAlert = false
    @Published var alertMessage = "Atención"
    @Published var currentQuestionIndex = 0
    @Published var selectedOptionIndex = -1
    @Published var timeRemaining = 20
    @Published var isAnswered = false
    @Published var score = 0
    @Published var totalScore = 0
    @Published var preguntaCounter = 1
    @Published var isShowingResultadoView = false
    @Published var buttonText = "CONFIRMAR"
    @Published var displayMessage = "Sin miedo, elige una opción"
    @Published var isOptionSelected = false
    @Published var mistakes = 0
    @Published var answerIsCorrect: Bool? = nil
    @Published var isQuizCompleted = false
    @Published var selectedIncorrectAnswer = false
    @Published var questionTextColor = Color.black
    @Published var shouldFlashCorrectAnswer = false
    @Binding var player: AVAudioPlayer?
    @Published var selectedAnswerIsIncorrect = false
    @Published var resetFlashingSignal = false
    @Published var answerStatusMessage: String = ""
    @Published var questionsShownCount = 0
    
    
    
    
    init(player: Binding<AVAudioPlayer?> = .constant(nil)) {
        self._player = player
        if let questions = dbHelper.getRandomQuestions(count: 10) {
            self.randomQuestions = questions
        } else {
            self.randomQuestions = [] // or handle this situation appropriately
        }
        loadSoundEffects(player: player)
        startCountdownTimer()
        print("Fetched \(self.randomQuestions.count) random questions.")
    }
    
    
    var currentQuestion: QuizQuestion {
        return randomQuestions[currentQuestionIndex]
    }
    
    func startCountdownTimer() {
        timer?.invalidate()
        
        if currentQuestionIndex < randomQuestions.count {
            timeRemaining = 20
            
            // 🔊 Play countdown sound immediately when timer starts
            playCountdownSound()
            
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
    
   
    
    func playCountdownSound() {
        countdownSound?.stop()
        countdownSound?.currentTime = 0
        countdownSound?.numberOfLoops = -1
        countdownSound?.play()
    }
    
    func StopCountdownSound() {
         countdownSound?.stop()
       }
    
            
    private func updateButtonTextForNextAction() {
        buttonText = preguntaCounter < randomQuestions.count ? "SIGUIENTE" : "TERMINAR"
    }
    
    private func handleCorrectAnswer() {
        score += 1
        totalScore += 500
        rightSoundEffect?.play()
        answerStatusMessage = "RESPUESTA CORRECTA"
        answerIsCorrect = true
        selectedIncorrectAnswer = false
        questionTextColor = Color.darkGreen
    }

    
    func handleIncorrectAnswer() {
        mistakes += 1
        wrongSoundEffect?.play()
        answerStatusMessage = "RESPUESTA INCORRECTA"
        answerIsCorrect = false
        selectedIncorrectAnswer = true
        selectedAnswerIsIncorrect = true
        shouldFlashCorrectAnswer = true
        questionTextColor = Color.darkRed
    }

    func checkAnswer() {
        guard !isAnswered else { return }
        isAnswered = true
        timer?.invalidate()

        let correctOptionIndex = randomQuestions[currentQuestionIndex].correctAnswerIndex
        print("Question ID: \(randomQuestions[currentQuestionIndex].id), Selected Option Index: \(selectedOptionIndex), Correct Option: \(correctOptionIndex)")

        if selectedOptionIndex == correctOptionIndex {
            handleCorrectAnswer()
        } else {
            handleIncorrectAnswer()
        }
    
        updateButtonTextPostAnswer()
    }
    
    private func updateButtonTextPostAnswer() {
        if preguntaCounter >= 10 {
            buttonText = "TERMINAR"
        } else {
            buttonText = "SIGUIENTE"
        }
    }
    
    func showNextQuestion() {
            if questionsShownCount < 9 { // 9 because we start counting from 0
                currentQuestionIndex += 1
                prepareForNewQuestion()
                questionsShownCount += 1
            } else {
                // This is the last question, handle the end of the quiz
                print("Last question answered. Preparing to finish quiz.")
                finishQuiz()
            }
        }

    
    private func prepareForNewQuestion() {
        print("Preparing for new question. Index: \(currentQuestionIndex), ID: \(randomQuestions[currentQuestionIndex].id), Pregunta Counter: \(preguntaCounter + 1)")
        isAnswered = false
        selectedOptionIndex = -1
        answerStatusMessage = "" // Reset the answer status message
        questionTextColor = .white // Reset the question text color

        // No need to assign currentQuestion, it's computed based on currentQuestionIndex

        preguntaCounter += 1
        resetForNewQuestion()
        resetFlashingSignal = true
        print("New question prepared. Current Question Index: \(currentQuestionIndex), Question ID: \(randomQuestions[currentQuestionIndex].id)")
    }


    private func resetForNewQuestion() {
        timeRemaining = 15
        answerIsCorrect = nil
        buttonText = "CONFIRMAR"
        startCountdownTimer()
        selectedIncorrectAnswer = false
        shouldFlashCorrectAnswer = false
        questionTextColor = Color.black
    
    }
    
    private func showAlertCompletedQuestions() {
        SoundManager.shared.playMagic()
        print("All questions completed. Showing completion alert.")
        alertMessage = "Atención."
        displayMessage = "Felicidades campeón. Has completado el Modo Libre. Prueba el Modo Competición"
        showAlert = true
    }

    func finishQuiz() {
        let aciertos = score
        let puntuacion = totalScore
        let errores = mistakes
        UserDefaults.standard.set(aciertos, forKey: "aciertos")
        UserDefaults.standard.set(puntuacion, forKey: "puntuacion")
        UserDefaults.standard.set(errores, forKey: "errores")
        isQuizCompleted = true
        let roundQuestionIDs = randomQuestions.map { $0.id }
           QuizDBHelper.shared.markQuestionsAsShown(with: roundQuestionIDs)
        print("Quiz finished. Correct Answers: \(aciertos), Total Score: \(puntuacion), Mistakes: \(errores), Quiz Completed: \(isQuizCompleted)")
    }

    private func loadSoundEffects(player: Binding<AVAudioPlayer?>) {
        rightSoundEffect = loadSoundEffect(named: "right", fileExtension: "wav")
        wrongSoundEffect = loadSoundEffect(named: "notright", fileExtension: "wav")
        countdownSound = loadSoundEffect(named: "countdown1", fileExtension: "mp3")
        self.player = player.wrappedValue
    }

    private func loadSoundEffect(named name: String, fileExtension: String) -> AVAudioPlayer? {
        if let path = Bundle.main.path(forResource: name, ofType: fileExtension) {
            let url = URL(fileURLWithPath: path)
            do {
                let soundEffect = try AVAudioPlayer(contentsOf: url)
                soundEffect.prepareToPlay()
                return soundEffect
            } catch {
                print("Error loading sound effect '\(name).\(fileExtension)': \(error.localizedDescription)")
            }
        } else {
            print("Sound file \(name).\(fileExtension) not found in bundle.")
        }
        return nil
    }
    
    

    private func prepareCountdownSound() {
        guard let url = Bundle.main.url(forResource: "countdown1", withExtension: "mp3") else {
            fatalError("Countdown sound file not found")
        }
        do {
            countdownSound = try AVAudioPlayer(contentsOf: url)
            countdownSound?.prepareToPlay()
        } catch {
            print("Failed to prepare countdown sound: \(error)")
        }
    }

    private func showAlertForNoSelection() {
        showAlert = true
    }
}
