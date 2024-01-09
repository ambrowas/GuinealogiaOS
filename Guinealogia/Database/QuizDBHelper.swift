import Foundation

class QuizDBHelper {
    private let jsonFileName = "quiz_questions"
    var shownQuestionIds: Set<Int> = []

    init() {
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

        let availableQuestions = questions.filter { !shownQuestionIds.contains($0.id) }
        if availableQuestions.count < count {
            print("Warning: Requested \(count) questions, but only \(availableQuestions.count) are available.")
            return nil
        } else {
            let shuffledQuestions = availableQuestions.shuffled().prefix(count)
            shuffledQuestions.forEach { shownQuestionIds.insert($0.id) }
            saveShownQuestionIds()
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

    func saveShownQuestionIds() {
        if let shownIdsData = try? JSONEncoder().encode(shownQuestionIds) {
            UserDefaults.standard.set(shownIdsData, forKey: "ShownQuestions")
            print("Saved shown question IDs to UserDefaults: \(shownQuestionIds)")
        } else {
            print("Failed to encode shown question IDs or save to UserDefaults.")
        }
    }

    func resetShownQuestions() {
        print("Resetting shown questions.")
        shownQuestionIds.removeAll()
        UserDefaults.standard.removeObject(forKey: "ShownQuestions")
        print("After reset, shownQuestionIds: \(shownQuestionIds)")
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
    
    func printShownQuestionIds() {
        print("Current shownQuestionIds: \(shownQuestionIds)")
    }
}
