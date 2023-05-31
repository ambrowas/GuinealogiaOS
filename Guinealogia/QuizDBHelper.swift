import SQLite
import Foundation

class QuizDBHelper {
    private let databaseName = "Guinealogia"
    private let databaseExtension = "db"
    private let databasePath: String
    private let database: Connection
    
    init() {
        guard let databasePath = Bundle.main.path(forResource: databaseName, ofType: databaseExtension) else {
            fatalError("Database file not found.")
        }
        
        self.databasePath = databasePath
        
        do {
            database = try Connection(databasePath)
        } catch {
            fatalError("Failed to establish database connection: \(error.localizedDescription)")
        }
    }
    
    func getRandomQuestions(count: Int) -> [QuizQuestion] {
        var questionList: [QuizQuestion] = []
        
        let tableName = Table(QuizContract.QuestionsTable.tableName)
        let questionColumn = Expression<String>(QuizContract.QuestionsTable.columnQuestion)
        let option1Column = Expression<String>(QuizContract.QuestionsTable.columnOption1)
        let option2Column = Expression<String>(QuizContract.QuestionsTable.columnOption2)
        let option3Column = Expression<String>(QuizContract.QuestionsTable.columnOption3)
        let answerNrColumn = Expression<Int>(QuizContract.QuestionsTable.columnAnswerNr)
        
        let query = tableName
            .select(questionColumn, option1Column, option2Column, option3Column, answerNrColumn)
            .order(Expression<Int>.random())
            .limit(count)
        
        do {
            for row in try database.prepare(query) {
                let questionText = row[questionColumn]
                let option1 = row[option1Column]
                let option2 = row[option2Column]
                let option3 = row[option3Column]
                let answerNr = row[answerNrColumn]
                
                let question = QuizQuestion(question: questionText, option1: option1, option2: option2, option3: option3, answerNr: answerNr)
                questionList.append(question)
            }
        } catch {
            print("Failed to fetch questions: \(error.localizedDescription)")
        }
        
        return questionList
    }
}

