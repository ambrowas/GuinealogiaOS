import SwiftUI
import FirebaseDatabase

class UserViewModel: ObservableObject {
    @Published var fullname = ""
    @Published var email = ""
    @Published var telefono = ""
    @Published var barrio = ""
    @Published var ciudad = ""
    @Published var pais = ""
    @Published var profilePicture = ""
    @Published var currentGameAciertos = 0
    @Published var currentGameFallos = 0
    @Published var currentGamePuntuacion = 0
    @Published var highestScore = 0
    @Published var positionInLeaderboard = 0

    
    func fetchUserData(userId: String) {
        let ref = Database.database().reference().child("user").child(userId)
        
        ref.observeSingleEvent(of: .value) { snapshot, error in
            if let error = error {
                print("Error fetching user data: \(error)")
                return
            }
            
            if let dict = snapshot.value as? [String: Any],
               let fullname = dict["fullname"] as? String,
               let highestScore = dict["highestScore"] as? Int {
                DispatchQueue.main.async {
                    // Update the user data here
                    self.fullname = fullname
                    self.highestScore = highestScore
                }
            }
        }
    }
}
