import Foundation

class QuizDBHelper {
    private let jsonFileName = "quiz_questions"
    private var shownQuestionIds: Set<Int> = []
    init() {
          loadShownQuestionIds()
      }

    
    private func loadQuestionsFromJSON() -> [QuizQuestion]? {
        guard let url = Bundle.main.url(forResource: jsonFileName, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Error: Cannot find JSON file named \(jsonFileName).")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let questions = try decoder.decode([QuizQuestion].self, from: data)
            print("Loaded question IDs from JSON: \(questions.map { $0.id })")
            return questions
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }
    
    func getRandomQuestions(count: Int) -> [QuizQuestion] {
        guard let questions = loadQuestionsFromJSON() else {
            print("Failed to load questions from JSON")
            return []
        }

        let availableQuestions = questions.filter { !shownQuestionIds.contains($0.id) }
        let shuffledQuestions = availableQuestions.shuffled().prefix(count)
        
        if shuffledQuestions.count < count {
            print("Warning: Requested \(count) questions, but only \(shuffledQuestions.count) are available.")
        }

        // Update the shown questions set
        shuffledQuestions.forEach { shownQuestionIds.insert($0.id) }
        saveShownQuestionIds()
        print("Selected question IDs: \(shuffledQuestions.map { $0.id })")
        return Array(shuffledQuestions)
    }

    private func loadShownQuestionIds() {
        if let shownIdsData = UserDefaults.standard.data(forKey: "ShownQuestions"),
           let shownIds = try? JSONDecoder().decode(Set<Int>.self, from: shownIdsData) {
            shownQuestionIds = shownIds
            print("Loaded previously shown question IDs from UserDefaults: \(shownQuestionIds)")
        } else {
            print("No previously shown question IDs found in UserDefaults or failed to decode.")
        }
    }

    private func saveShownQuestionIds() {
        if let shownIdsData = try? JSONEncoder().encode(shownQuestionIds) {
            UserDefaults.standard.set(shownIdsData, forKey: "ShownQuestions")
            // Log the total number of saved shown question IDs.
            print("Saved shown question IDs to UserDefaults: \(shownQuestionIds)")
            print("Total number of saved shown questions: \(shownQuestionIds.count)")
        } else {
            print("Failed to encode shown question IDs or save to UserDefaults.")
        }
    }
    
    
    func resetShownQuestions() {
        shownQuestionIds.removeAll()
        UserDefaults.standard.removeObject(forKey: "ShownQuestions")
        print("Reset shown question IDs and cleared UserDefaults.")
    }
    
    func markAllButTwoQuestionsAsUsed() {
            guard let questions = loadQuestionsFromJSON(), questions.count > 2 else {
                print("Not enough questions to mark as used.")
                return
            }

            // Reset the shownQuestionIds to make sure it's empty
            shownQuestionIds.removeAll()

            // Add all but two question IDs to the shownQuestionIds set
            questions.dropLast(2).forEach { shownQuestionIds.insert($0.id) }

            // Save the updated shownQuestionIds
            saveShownQuestionIds()
        print("Marked all but two questions as used. Used question IDs: \(shownQuestionIds)")
        }
    
   }
    
    


