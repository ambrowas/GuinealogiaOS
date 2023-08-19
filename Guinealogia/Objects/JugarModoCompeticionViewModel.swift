import SwiftUI
import AVFoundation
import FirebaseFirestore
import FirebaseDatabase
import FirebaseAuth
import Combine

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
      
      init(userId: String, userData: UserData) { // Modify the initializer
          self.userId = userId
          self.userData = userData
          prepareCountdownSound()
          loadSoundEffects()
          optionSelections = Array(repeating: false, count: options.count)
        
          
          // Initialize button background colors with the default color
          buttonBackgroundColors = Array(repeating: Color(hue: 0.664, saturation: 0.935, brightness: 0.604), count: 3)
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

            // Filter out questions that have already been shown
            let unseenDocuments = documents.filter { document in
                return !(self?.shownQuestionIDs.contains(document.documentID))! ?? true
            }

            // If all questions have been shown, reset the list
            if unseenDocuments.isEmpty {
                self?.shownQuestionIDs.removeAll()
            }

            // Select a random question from the unseen questions
            let randomIndex = Int.random(in: 0..<unseenDocuments.count)
            let document = unseenDocuments[randomIndex]

            // Add the selected question's ID to the list of shown questions
            self?.shownQuestionIDs.insert(document.documentID)

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
      hasShownManyMistakesAlert = false // Reset the flag
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

      func startTimer() {
             initializeTimer()
         }

      private func initializeTimer() {
             timeRemaining = 15
             timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                 self?.reduceTime()
             }
         }

      private func reduceTime() {
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

      private func handleTimeExpiry() {
        print("handleTimeExpiry called")

        timer?.invalidate()
        playWrongSoundEffect()

        answerChecked = true
        answerIsCorrect = false
        mistakes += 1
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

      private func resetTimer() {
        timer?.invalidate()
        timer = nil
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
