import Foundation

class QuizDBHelper {
    static let shared = QuizDBHelper()
    private let jsonFileName = "quiz_questions"
    var shownQuestionIds: Set<Int> = []

   private init() {
        print("Initializing QuizDBHelper.")
        loadShownQuestionIds()
    }

    func loadQuestionsFromJSON() -> [QuizQuestion]? {
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

    func getRandomQuestions(count: Int) -> [QuizQuestion]? {
        guard let questions = loadQuestionsFromJSON() else {
            print("Failed to load questions from JSON")
            return nil
        }
        
        // Print the IDs of all questions loaded from JSON
        print("Loaded question IDs from JSON: \(questions.map { $0.id })")
        
        // Filter out the questions that have already been shown
        let availableQuestions = questions.filter { !shownQuestionIds.contains($0.id) }
         print("Available questions before fetching: \(availableQuestions.count)")

         if availableQuestions.count < count {
             print("Warning: Requested \(count) questions, but only \(availableQuestions.count) are available.")
             return nil
         } else {
             let shuffledQuestions = availableQuestions.shuffled().prefix(count)
             return Array(shuffledQuestions)
         
     }
    }


    func loadShownQuestionIds() {
        if let shownIdsData = UserDefaults.standard.data(forKey: "ShownQuestions"),
           let shownIds = try? JSONDecoder().decode(Set<Int>.self, from: shownIdsData) {
            shownQuestionIds = shownIds
            print("Loaded previously shown question IDs from UserDefaults: \(shownQuestionIds)")
        } else {
            print("No previously shown question IDs found in UserDefaults or failed to decode.")
        }
    }
    
    func markQuestionsAsShown(with ids: [Int]) {
        shownQuestionIds.formUnion(ids)
        saveShownQuestionIds()
    }
    
    func saveShownQuestionIds() {
        if let shownIdsData = try? JSONEncoder().encode(shownQuestionIds) {
            UserDefaults.standard.set(shownIdsData, forKey: "ShownQuestions")
            print("Attempting to save shown question IDs to UserDefaults: \(shownQuestionIds)")
            if UserDefaults.standard.synchronize() {
                print("UserDefaults successfully saved the shown question IDs.")
            } else {
                print("UserDefaults failed to save the shown question IDs immediately.")
            }
        } else {
            print("Failed to encode shown question IDs or save to UserDefaults.")
        }
    }

    func resetShownQuestions() {
        print("Resetting shown questions. Before reset, shownQuestionIds: \(shownQuestionIds)")
        shownQuestionIds.removeAll()
        UserDefaults.standard.removeObject(forKey: "ShownQuestions")
        if UserDefaults.standard.synchronize() {
            print("UserDefaults successfully removed the shown question IDs.")
        } else {
            print("UserDefaults failed to remove the shown question IDs immediately.")
        }
    }

    func markAllButTenQuestionsAsUsed() {
        guard let questions = loadQuestionsFromJSON(), questions.count > 10 else {
            print("Not enough questions to leave 10 unused.")
            return
        }

        shownQuestionIds.removeAll()

        // Use dropLast(10) to skip the last 10 questions, marking the rest as used
        questions.dropLast(10).forEach { shownQuestionIds.insert($0.id) }
        saveShownQuestionIds()
        print("Marked all but ten questions as used. Used question IDs: \(shownQuestionIds)")
    }
    
    func getNumberOfUnusedQuestions() -> Int {
           guard let questions = loadQuestionsFromJSON() else {
               return 0
           }

           let unusedQuestionsCount = questions.filter { !shownQuestionIds.contains($0.id) }.count
           return unusedQuestionsCount
       }
    
    func printShownQuestionIds() {
        print("Current shownQuestionIds: \(shownQuestionIds)")
    }
    
    func markAllQuestionsAsUsed() {
        let allIDs = Array(1...100)
        markQuestionsAsShown(with: allIDs)
        print("✅ Todas las preguntas han sido marcadas como jugadas (used).")
    }
}
