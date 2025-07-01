import Foundation
import SwiftUI

struct QuizQuestion: Decodable, Equatable {
    var id: Int
    var question: String
    var option1: String
    var option2: String
    var option3: String
    var answerNr: Int
    var textColor: Color = .black
    var explicacion: String? 

    var correctAnswerIndex: Int {
        return answerNr - 1 // Adjust to zero-based index
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case question
        case option1 = "OPTION1"
        case option2 = "OPTION2"
        case option3 = "OPTION3"
        case answerNr = "answer_nr"
        case explicacion
        // textColor is not included in the JSON
    }
}
