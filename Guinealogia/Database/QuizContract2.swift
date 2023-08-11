import FirebaseFirestore

protocol QuizContract2 {
    func fetchQuestion(completion: @escaping (QuizQuestion?) -> Void)
}

class FirestoreService: QuizContract2 {
    private let db = Firestore.firestore()

    func fetchQuestion(completion: @escaping (QuizQuestion?) -> Void) {
        db.collection("PREGUNTAS").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching documents: \(error?.localizedDescription ?? "")")
                completion(nil)
                return
            }

            if let document = documents.randomElement() {
                let data = document.data()
                let question = data["QUESTION"] as? String ?? ""
                let correctAnswer = data["ANSWER"] as? String ?? ""
                let category = data["CATEGORY"] as? String ?? ""
                let imageUrl = data["IMAGE"] as? String ?? ""
                let optionA = data["OPTION_A"] as? String ?? ""
                let optionB = data["OPTION_B"] as? String ?? ""
                let optionC = data["OPTION_C"] as? String ?? ""

                let quizQuestion = QuizQuestion(question: question, option1: optionA, option2: optionB, option3: optionC, answerNr: 0, textColor: .black)
                completion(quizQuestion)
            } else {
                completion(nil)
            }
        }
    }
}

