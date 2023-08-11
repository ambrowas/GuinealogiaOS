import SwiftUI
import AVFoundation
import FirebaseFirestore
import FirebaseDatabase
import FirebaseAuth

class JugarModoCompeticionViewModel: ObservableObject {
    @Published var currentQuestion: String = ""
    @Published var options: [String] = []
    @Published var score: Int = 0
    @Published var mistakes: Int = 0
    @Published var totalScore: Int = 0
    @Published var category: String = ""
    @Published var image: String = ""
    @Published var correctAnswer: String = ""
    @Published var timeRemaining: Int = 15
    @Published var selectedOptionIndex: Int? = nil
    @Published var isGamePaused: Bool = false
    private var timer: Timer?
    private var countdownSound: AVAudioPlayer?
    private var rightSoundEffect: AVAudioPlayer?
    private var wrongSoundEffect: AVAudioPlayer?
    private let firestore = Firestore.firestore()
    @Published private var buttonText: String = "CONFIRMAR"
    @Published var optionSelections: [Bool] = []
    var defaultButtonColor: Color = Color(hue: 0.664, saturation: 0.935, brightness: 0.604)
    @Published var buttonBackgroundColors: [Color] = []
    @Published var clickCount = 0
    @Published var showAlert = false
    @Published var showDoubleClickAlert = false
    private var tapCount = 0
    @Published var shouldShowTerminar: Bool = false
    var userId: String
    private var dbRef = Database.database().reference()
    @ObservedObject var userData: UserData
    @Published var shouldNavigateToGameOver: GameOverPresented? = nil
    @Published var showManyMistakesAlert: Bool = false
    @Published var showGameOverAlert: Bool = false
    @Published var answerChecked = false
    @Published var answerIsCorrect: Bool?
    
    var buttonConfirmar: String {
        buttonText
    }
    
    var shuffledOptions: [String] {
        options.shuffled()
    }
    
    init(userId: String, userData: UserData) { // Modify the initializer
        self.userId = userId
        self.userData = userData
        prepareCountdownSound()
        loadSoundEffects()
        optionSelections = Array(repeating: false, count: options.count)
        prepareCountdownSound()
        loadSoundEffects()
        
        // Initialize button background colors with the default color
        buttonBackgroundColors = Array(repeating: Color(hue: 0.664, saturation: 0.935, brightness: 0.604), count: 3)
    }
    
    func terminar(completion: @escaping () -> Void) {
        // Call the update functions
        updateCurrentGameValues(aciertos: score, fallos: mistakes, puntuacion: totalScore)
        updateAccumulatedValues(newAciertos: score, newFallos: mistakes, newPuntuacion: totalScore)
        updateHighestScore(newScore: totalScore)
        
        
        
        // After all the updates are done, set shouldNavigateToGameOver to true and call the completion handler
        shouldNavigateToGameOver = GameOverPresented()
        print("terminar function completed")
        completion()
    }
    
    
    
    func calculateNewPosition() -> Int {
        let sortedUsers = userData.users.sorted { $0.accumulatedPuntuacion > $1.accumulatedPuntuacion }
        if let currentUserIndex = sortedUsers.firstIndex(where: { $0.id == userId }) {
            return currentUserIndex + 1
        }
        return 0 // Return 0 if the current user is not found in the sorted array
    }
    
    
    func fetchQuestion() {
        firestore.collection("PREGUNTAS").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching questions: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            
            let randomIndex = Int.random(in: 0..<documents.count)
            let document = documents[randomIndex]
            
            let data = document.data()
            
            if let question = data["QUESTION"] as? String,
               let category = data["CATEGORY"] as? String,
               let image = data["IMAGE"] as? String,
               let optionA = data["OPTION A"] as? String,
               let optionB = data["OPTION B"] as? String,
               let optionC = data["OPTION C"] as? String,
               let answer = data["ANSWER"] as? String {
                DispatchQueue.main.async {
                    self?.selectedOptionIndex = nil // Clear all selections
                    self?.currentQuestion = question
                    self?.category = category
                    self?.image = image
                    self?.options = [optionA, optionB, optionC]
                    self?.correctAnswer = answer
                    self?.startTimer()
                }
            } else {
                print("Invalid data format")
                print("Fetching question...")
                print("Documents count: \(documents.count)")
                print("Data: \(data)")
                print("Fetched data: \(data)")
            }
        }
    }
    
    func fetchNextQuestion() {
        selectedOptionIndex = nil // Clear the selected option
        fetchQuestion()
        buttonText = "CONFIRMAR"
        buttonBackgroundColors = Array(repeating: Color(hue: 0.664, saturation: 0.935, brightness: 0.604), count: options.count)
    }
    
    func checkAnswer() {
        // Initially set answerChecked to false
        answerChecked = false

        // Check if an option has been selected
        if let selectedOptionIndex = selectedOptionIndex {
            let selectedOption = options[selectedOptionIndex]
            if selectedOption == correctAnswer {
                // If the answer is correct, play the right sound effect, increment the score and totalScore
                self.playRightSoundEffect()
                self.score += 1
                self.totalScore += 500

                // Indicate that an answer has been checked and it's correct
                answerIsCorrect = true
                answerChecked = true
            } else {
                // If the answer is incorrect, play the wrong sound effect, increment the mistakes and decrease the totalScore
                self.playWrongSoundEffect()
                self.mistakes += 1
                self.totalScore -= 500

                // If mistakes reach 5, call the terminar function and return
                if self.mistakes >= 5 {
                    self.terminar {
                        
                    }
                    return
                }

                // Indicate that an answer has been checked and it's incorrect
                answerIsCorrect = false
                answerChecked = true
            }
            resetTimer()
            buttonText = "SIGUIENTE"
        } else {
            showAlert = true
            return
        }

        // Reset the selected option after checking the answer
        self.selectedOptionIndex = nil
        self.shouldShowTerminar = true
    }

    
    private func startTimer() {
            timeRemaining = 15
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.timeRemaining -= 1

                // Play countdown sound when timeRemaining is between 1 and 5
                if self.timeRemaining <= 5 && self.timeRemaining > 0 {
                    self.playCountdownSound()
                }

                if self.timeRemaining == 0 {
                    self.timer?.invalidate() // Stop the timer
                    self.playWrongSoundEffect() // Play the "not right" sound effect

                    self.buttonText = "SIGUIENTE"  // Change the button text to "SIGUIENTE"
                    self.mistakes += 1
                    self.totalScore -= 500
                    self.selectedOptionIndex = nil
                        
                    // Show alerts based on the number of mistakes
                    if self.mistakes == 4 {
                        // Show ManyMistakesAlert
                        // You'll have to implement this yourself according to your application's design
                        self.showManyMistakesAlert = true
                    } else if self.mistakes == 5 {
                        // Show GameOverAlert
                        // You'll have to implement this yourself according to your application's design
                        self.showGameOverAlert = true
                    }
                }
            }
        }

    
    private func playCountdownSound() {
        guard let url = Bundle.main.url(forResource: "countdown", withExtension: "wav") else {
            fatalError("Countdown sound file not found")
        }
        
        do {
            countdownSound = try AVAudioPlayer(contentsOf: url)
            countdownSound?.play()
        } catch {
            print("Failed to play countdown sound: \(error)")
        }
    }
    
    private func resetTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func prepareCountdownSound() {
        guard let url = Bundle.main.url(forResource: "countdown", withExtension: "wav") else {
            fatalError("Countdown sound file not found")
        }
        
        do {
            countdownSound = try AVAudioPlayer(contentsOf: url)
            countdownSound?.prepareToPlay()
        } catch {
            print("Failed to prepare countdown sound: \(error)")
        }
    }
    
    private func loadSoundEffects() {
        guard let rightURL = Bundle.main.url(forResource: "right", withExtension: "wav") else {
            fatalError("Right sound effect file not found")
        }
        
        guard let wrongURL = Bundle.main.url(forResource: "notright", withExtension: "wav") else {
            fatalError("Wrong sound effect file not found")
        }
        
        do {
            rightSoundEffect = try AVAudioPlayer(contentsOf: rightURL)
            rightSoundEffect?.prepareToPlay()
            
            wrongSoundEffect = try AVAudioPlayer(contentsOf: wrongURL)
            wrongSoundEffect?.prepareToPlay()
        } catch {
            print("Failed to load sound effects: \(error)")
        }
    }
    
    private func playRightSoundEffect() {
        rightSoundEffect?.play()
    }
    
    private func playWrongSoundEffect() {
        wrongSoundEffect?.play()
    }
    
    public func resetButtonColors() {
        buttonBackgroundColors = Array(repeating: defaultButtonColor, count: options.count)
    }
    
    func updateButtonBackgroundColors() {
        var colors = [Color]()
        for index in options.indices {
            if index == selectedOptionIndex {
                colors.append(Color(hue: 0.315, saturation: 0.953, brightness: 0.335))
            } else {
                colors.append(Color(hue: 0.664, saturation: 0.935, brightness: 0.604))
            }
        }
        buttonBackgroundColors = colors
    }
    
    func updateCurrentGameValues(aciertos: Int, fallos: Int, puntuacion: Int) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userRef = dbRef.child("user").child(userId)
        
        let gameStats: [String: Any] = [
            "currentGameAciertos": aciertos,
            "currentGameFallos": fallos,
            "currentGamePuntuacion": puntuacion
        ]
        
        userRef.updateChildValues(gameStats) { (error, dbRef) in
            if let error = error {
                print("Error updating values: \(error)")
            } else {
                print("Successfully updated values")
            }
        }
    }
    
    func updateAccumulatedValues(newAciertos: Int, newFallos: Int, newPuntuacion: Int) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userRef = dbRef.child("user").child(userId)
        
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            if let userData = snapshot.value as? [String: Any],
               let currentAciertos = userData["accumulatedAciertos"] as? Int,
               let currentFallos = userData["accumulatedFallos"] as? Int,
               let currentPuntuacion = userData["accumulatedPuntuacion"] as? Int {
                
                let updatedAciertos = currentAciertos + newAciertos
                let updatedFallos = currentFallos + newFallos
                let updatedPuntuacion = currentPuntuacion + newPuntuacion
                
                let updates: [String: Any] = [
                    "accumulatedAciertos": updatedAciertos,
                    "accumulatedFallos": updatedFallos,
                    "accumulatedPuntuacion": updatedPuntuacion
                ]
                
                userRef.updateChildValues(updates) { (error, dbRef) in
                    if let error = error {
                        print("Error updating values: \(error)")
                    } else {
                        print("Successfully updated values")
                    }
                }
            }
        }
    }
    
    func updateHighestScore(newScore: Int) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userRef = dbRef.child("user").child(userId)
        
        userRef.child("highestScore").observeSingleEvent(of: .value) { (snapshot) in
            if let highestScore = snapshot.value as? Int, newScore > highestScore {
                userRef.updateChildValues([
                    "highestScore": newScore
                ]) { (error, _) in
                    if let error = error {
                        print("Error updating highest score: \(error.localizedDescription)")
                    } else {
                        print("Successfully updated highest score.")
                    }
                }
            }
        }
    }
}
