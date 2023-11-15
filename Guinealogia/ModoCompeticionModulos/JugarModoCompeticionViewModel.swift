import SwiftUI
import AVFoundation
import FirebaseFirestore
import FirebaseDatabase
import FirebaseAuth
import Combine

class JugarModoCompeticionViewModel: ObservableObject {
   // @Published var currentQuestion: String = ""
    @Published var options: [String] = []
    @Published var score: Int = 0
    @Published var mistakes: Int = 0
    @Published var totalScore: Int = 0
    @Published var category: String = ""
    @Published var image: String = ""
    @Published var correctAnswer: String = ""
    @Published var timeRemaining: Int = 15
    //@Published var selectedOptionIndex: Int? = nil
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
    @Published var shouldNavigateToGameOver: Bool = false
    @Published var showManyMistakesAlert: Bool = false
    @Published var showGameOverAlert: Bool = false
    @Published var answerChecked = false
    @Published var answerIsCorrect: Bool?
    @Published var showXmarkImage: Bool = false
    var questionProcessed: Bool = false
    var showConfirmButton: Bool = true
    var showNextButton: Bool = false
    var showEndButton: Bool = false
    @Published var activeAlert: ActiveAlert?
    @Published var hasShownManyMistakesAlert = false
    var endGameAlertPublisher = PassthroughSubject<Void, Never>()
    var manyMistakesAlertPublisher = PassthroughSubject<Void, Never>()
    var gameOverAlertPublisher = PassthroughSubject<Void, Never>()
    private var shownQuestionIDs: Set<String> = []
    @Published var isAlertBeingDisplayed: Bool = false
    @Published var showAnswerStatus: Bool = false
    let timeExpired = PassthroughSubject<Bool, Never>()
    var lastDocumentSnapshot: DocumentSnapshot?
    var questionCache: [QueryDocumentSnapshot] = []
    var questionManager: QuestionManager?
    var currentQuestion: QuestionII?
    var selectedOptionIndex: Int?
    var currentQuestionNumber: String? { // Computed property to get the question number
        return currentQuestion?.number // Or however you access the number in your Question type
        }
    
    
        
        enum ActiveAlert: Identifiable {
            case showAlert, showEndGameAlert, showGameOverAlert, showManyMistakesAlert
            
            var id: Int {
                switch self {
                case .showAlert:
                    return 0
                case .showEndGameAlert:
                    return 1
                case .showGameOverAlert:
                    return 2
                case .showManyMistakesAlert:
                    return 3
                }
            }
        }
        
    var buttonConfirmar: String {
        buttonText
    }
    
    var shuffledOptions: [String] {
        options.shuffled()
    }
    
    init(userId: String, userData: UserData) {
        // Initialize your other properties
        
        self.userId = userId
        self.userData = userData
        optionSelections = Array(repeating: false, count: options.count)
        buttonBackgroundColors = Array(repeating: Color(hue: 0.664, saturation: 0.935, brightness: 0.604), count: 3)
        self.questionManager = QuestionManager(realTimeDatabaseReference: self.dbRef, firestore: self.firestore, userID: self.userId)

        // Load and prepare the sound players
        if let countdownURL = Bundle.main.url(forResource: "countdown", withExtension: "wav"),
           let rightURL = Bundle.main.url(forResource: "right", withExtension: "wav"),
           let wrongURL = Bundle.main.url(forResource: "notright", withExtension: "wav") {
            do {
                countdownSound = try AVAudioPlayer(contentsOf: countdownURL)
                countdownSound?.prepareToPlay()
                
                rightSoundEffect = try AVAudioPlayer(contentsOf: rightURL)
                rightSoundEffect?.prepareToPlay()
                
                wrongSoundEffect = try AVAudioPlayer(contentsOf: wrongURL)
                wrongSoundEffect?.prepareToPlay()
            } catch {
                print("Failed to load sound effects: \(error)")
            }
        } else {
            print("Sound effect files not found in the bundle.")
        }
    }
    
    
           
                func fetchNextQuestion() {
            let unusedQuestionsCount = DatabaseManager.shared.countUnusedQuestions()
            print("fetchNextQuestion - Remaining unused questions in the database: \(unusedQuestionsCount)")

            if unusedQuestionsCount > 8 {
                print("fetchNextQuestion - Sufficient unused questions available, presenting random question.")
                presentRandomQuestionAndUpdateUI()
            } else if unusedQuestionsCount == 8 {
                updateBatchIfNeeded()
            } else if unusedQuestionsCount == 5 {
                print("fetchNextQuestion - Exactly 5 unused questions left, starting batch process.")
                startNewBatchProcess()
            } else {
                print("fetchNextQuestion - \(unusedQuestionsCount) or fewer unused questions available, presenting random question while waiting for more.")
                presentRandomQuestionAndUpdateUI()
            }
        }

          private func startNewBatchProcess() {
// Implement the logic to start a new batch process
// For example, creating a new instance of ViewModel or calling a method to start the process
//let viewModel = MenuModoCompeticionViewModel()
//viewModel.checkAndStartBatchProcess()
   self.fetchQuestionBatch()
              
}
    
    
            private func updateBatchIfNeeded() {
        guard let questionManager = questionManager else {
            print("fetchNextQuestion - questionManager is nil.")
            // Handle the case where questionManager is nil if necessary
            return
        }

        questionManager.updateCurrentBatchInRealtime { (success, error) in
            DispatchQueue.main.async {
                if success {
                    print("fetchNextQuestion - Current batch updated successfully.")
                    self.presentRandomQuestionAndUpdateUI()
                } else {
                    print("fetchNextQuestion - Failed to update current batch.")
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    }
                    // Consider additional error handling here if necessary
                }
            }
        }
    }

    func fetchQuestionBatch() {
        print("fetchQuestionBatch - Starting background fetch process for new questions.")

        questionManager?.fetchCurrentBatchForUser { [weak self] batchNumber in
            guard let strongSelf = self else {
                print("fetchQuestionBatch - Self is nil, aborting batch fetch process.")
                return
            }

            if let currentUserID = Auth.auth().currentUser?.uid {
                print("fetchQuestionBatch - Fetched currentBatch \(batchNumber) for user with ID: \(currentUserID).")
            } else {
                print("fetchQuestionBatch - Fetched currentBatch \(batchNumber) but no user is currently logged in.")
            }

            strongSelf.questionManager?.fetchShuffledOrderForBatch(batchNumber: batchNumber) { shuffledOrder in
                print("fetchQuestionBatch - Fetched shuffled order for batch successfully.")

                strongSelf.questionManager?.fetchQuestionsBasedOnShuffledOrder(shuffledOrder: shuffledOrder) { fetchedDocuments in
                    print("fetchQuestionBatch - Fetched questions based on shuffled order successfully.")

                    DatabaseManager.shared.deleteAllButLastFiveUnusedQuestions {
                        print("fetchQuestionBatch - Cleaned up local database, now have at least 5 unused questions.")
                    }

                    if fetchedDocuments.isEmpty {
                        print("Adequate unused questions available.")
                        // Present the next available question
                        self?.questionManager?.presentNextAvailableQuestion()
                    } else {
                        let group = DispatchGroup()
                        var totalInsertedQuestions = 0

                        for document in fetchedDocuments {
                            group.enter()
                            if let question = QuestionII(document: document) {
                                print("Inserting question with ID: \(question.number)")
                                
                                DatabaseManager.shared.insertQuestion(question: question) { success in
                                    if success {
                                        totalInsertedQuestions += 1
                                    } else {
                                        print("Failed to insert question with ID: \(question.number)")
                                    }
                                    group.leave()
                                }
                            } else {
                                print("Document conversion to Question failed.")
                                group.leave()
                            }
                        }

                        group.notify(queue: .main) {
                            print("Insertion complete. Total inserted: \(totalInsertedQuestions)")
                            // Present the next available question
                            self?.questionManager?.presentNextAvailableQuestion()
                        }
                    }
                }
            }
        }
    }


    
          
    
            func presentRandomQuestion() {
if let question = DatabaseManager.shared.fetchRandomQuestionFromLocalDatabase() {
DispatchQueue.main.async {
// Set the current question and its properties
self.currentQuestion = question
self.options = [question.optionA, question.optionB, question.optionC]
self.correctAnswer = question.answer
self.category = question.category
self.image = question.image
self.startTimer()
}
}
}
    
            private func presentRandomQuestionAndUpdateUI() {
        presentRandomQuestion()
        updateUIForNextQuestion()
    }

            func updateUIForNextQuestion() {
        // Update UI elements for the next question
        buttonText = "CONFIRMAR"
        buttonBackgroundColors = Array(repeating: Color(hue: 0.664, saturation: 0.935, brightness: 0.604), count: options.count)
        print("fetchNextQuestion - UI updated with new question details.")
    }

        
            func handleQuestionDocument(document: DocumentSnapshot) {
        let data = document.data()
        
        if let questionText = data?["QUESTION"] as? String,
           let category = data?["CATEGORY"] as? String,
           let image = data?["IMAGE"] as? String,
           let optionA = data?["OPTION A"] as? String,
           let optionB = data?["OPTION B"] as? String,
           let optionC = data?["OPTION C"] as? String,
           let answer = data?["ANSWER"] as? String,
           let number = data?["NUMBER"] as? String { // Assume "NUMBER" is the key for the question number
            
            let question = QuestionII(answer: answer, category: category, image: image, number: number, optionA: optionA, optionB: optionB, optionC: optionC, questionText: questionText)
            
            DispatchQueue.main.async {
                self.selectedOptionIndex = nil // Clear all selections
                self.currentQuestion = question // Assign the newly created QuestionII instance
                self.startTimer()
            }
        } else {
            print("Invalid data format")
            print("Fetching question...")
            print("Data: \(data ?? [:])")
            print("Fetched data: \(data ?? [:])")
        }
    }

            func checkAnswer() {
        // Check if an option has been selected
        if let selectedOptionIndex = selectedOptionIndex {
            let selectedOption = options[selectedOptionIndex]
            
            if selectedOption == correctAnswer {
                // Correct answer logic
                playRightSoundEffect()
                score += 1
                totalScore += 500
                answerIsCorrect = true
            } else {
                // Incorrect answer logic
                playWrongSoundEffect()
                mistakes += 1
                totalScore -= 500
                
                // Check for game over condition
                if mistakes >= 5 {
                    terminar {}
                    return
                }
                answerIsCorrect = false
            }
            
            // Mark the question as used regardless of the answer's correctness
            if let questionNumber = currentQuestion?.number {
                DatabaseManager.shared.markQuestionAsUsed(questionNumber: questionNumber)
            } else {
                print("Error: currentQuestionNumber is nil")
            }
            
            // Proceed with post-answer logic
            answerChecked = true
            resetTimer()
            buttonText = "SIGUIENTE"
            shouldShowTerminar = true
            
        } else {
            // No option has been selected, show an alert
            showAlert = true
        }
        
        // Reset the selected option after checking the answer
        selectedOptionIndex = nil
    }
    
            func startTimer() {
                initializeTimer()
            }
            
            func initializeTimer() {
            timeRemaining = 15
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.reduceTime()
            }
        }
            
            func reduceTime() {
                // Check if the alert is being displayed
                if isAlertBeingDisplayed {
                    // If the alert is being displayed, do not reduce the time
                    return
                }
                
                timeRemaining -= 1
                
                if timeRemaining <= 5 && timeRemaining > 0 {
                    playCountdownSound()
                }
                
                if timeRemaining == 0 {
                    handleTimeExpiry()
                }
            }
            
            func handleTimeExpiry() {
            print("handleTimeExpiry called")
            
            timer?.invalidate()
            playWrongSoundEffect()
            
            answerChecked = true
            answerIsCorrect = false
            mistakes += 1
            timeExpired.send(true) // Modified line
            questionProcessed = true
            
            buttonText = "SIGUIENTE"
            
            // Check the number of mistakes and trigger the appropriate alert
            if self.mistakes == 4 {
                // If the user is on 4 mistakes, display the Many Mistakes Alert
                self.triggerManyMistakesAlert()
                self.hasShownManyMistakesAlert = true
                print("Triggered Many Mistakes Alert")
            } else if self.mistakes >= 5 {
                // If the user is on its 5th mistake or more, trigger the GameOverAlert
                self.triggerGameOverAlert()
                print("Triggered Game Over Alert")
            }
        }
            
            func triggerGameOverAlert() {
                print("Triggering Game Overalert...")
                isAlertBeingDisplayed = true
                activeAlert = .showGameOverAlert
                objectWillChange.send() // If needed, trigger a manual view update
            }
            
            func triggerManyMistakesAlert() {
                print("Triggering many mistakes alert...")
                isAlertBeingDisplayed = true
                activeAlert = .showManyMistakesAlert
                objectWillChange.send() // If needed, trigger a manual view update
            }
            
            func triggerEndGameAlert() {
                print("Triggering end game alert...")
                isAlertBeingDisplayed = true
                activeAlert = .showEndGameAlert
                objectWillChange.send() // If needed, trigger a manual view update
            }
            
            func resetTimer() {
                timer?.invalidate()
                timer = nil
            }
            
            func playCountdownSound() {
                countdownSound?.play()
            }
            
            func prepareCountdownSound() {
                guard let url = Bundle.main.url(forResource: "countdown", withExtension: "wav") else {
                    print("Countdown sound file not found")
                    return
                }
                
                do {
                    countdownSound = try AVAudioPlayer(contentsOf: url)
                    countdownSound?.prepareToPlay()
                } catch {
                    print("Failed to prepare countdown sound: \(error)")
                }
            }
            
            func loadSoundEffects() {
                guard let rightURL = Bundle.main.url(forResource: "right", withExtension: "wav") else {
                    print("Right sound effect file not found")
                    return
                }
                
                guard let wrongURL = Bundle.main.url(forResource: "notright", withExtension: "wav") else {
                    print("Wrong sound effect file not found")
                    return
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
            
            func playRightSoundEffect() {
                rightSoundEffect?.play()
            }
            
            func playWrongSoundEffect() {
                wrongSoundEffect?.play()
            }
            
            func resetButtonColors() {
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
            
            func terminar(completion: @escaping () -> Void) {
                // Invalidate and stop the timer
                timer?.invalidate()
                timer = nil
                
                // Call the update functions
                updateCurrentGameValues(aciertos: score, fallos: mistakes, puntuacion: totalScore)
                updateAccumulatedValues(newAciertos: score, newFallos: mistakes, newPuntuacion: totalScore)
                updateHighestScore(newScore: totalScore)
                
                // After all the updates are done, set shouldNavigateToGameOver to true and call the completion handler
                shouldNavigateToGameOver = true
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
            
        }
        

