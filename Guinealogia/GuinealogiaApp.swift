
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseDatabase
import FirebaseAuth

@main
struct GuinealogiaApp: App {
    @StateObject private var authService = AuthService()

    init() {
        FirebaseApp.configure()
        
    }
    func sanitize(input: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: ".#$[]")
        return input.components(separatedBy: invalidCharacters).joined(separator: "")
    }


    func testDatabaseAccess() {
        let databaseRef = Database.database().reference()
        databaseRef.child("test").setValue("Hello, Firebase!") { error, _ in
            if let error = error {
                print("Error writing to database: \(error.localizedDescription)")
            } else {
                print("Database access is configured correctly")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(authService)
        }
    }
}
