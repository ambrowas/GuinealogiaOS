//
//  Quiz Contract.swift
//  Guinealogia
//
//  Created by ELEBI on 5/29/23.
//

import SwiftUI

struct QuizQuestion {
    var question: String
    var option1: String
    var option2: String
    var option3: String
    var answerNr: Int
    var textColor: Color // New property for text color

    init(question: String, option1: String, option2: String, option3: String, answerNr: Int, textColor: Color = .black) {
        self.question = question
        self.option1 = option1
        self.option2 = option2
        self.option3 = option3
        self.answerNr = answerNr
        self.textColor = textColor
    }
}


struct QuizContract {
    struct QuestionsTable {
        static let tableName = "quiz_questions"
        static let columnQuestion = "question"
        static let columnOption1 = "option1"
        static let columnOption2 = "option2"
        static let columnOption3 = "option3"
        static let columnAnswerNr = "answer_nr"
    }
}

