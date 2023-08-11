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
    @Published var accumulatedPuntuacion = 0
    @Published var accumulatedAciertos = 0
    @Published var accumulatedFallos = 0
    @Published var positionInLeaderboard = 0
    
    
    
    
    
    func fetchUserData(userId: String) {
        let ref = Database.database().reference().child("user").child(userId)
        
        ref.observeSingleEvent(of: .value) { snapshot, error in
            if let error = error {
                print("Error fetching user data: \(error)")
                return
            }
            
            if let dict = snapshot.value as? [String: Any] {
                DispatchQueue.main.async {
                    // Update the user data here
                    self.fullname = dict["fullname"] as? String ?? ""
                    self.highestScore = dict["highestScore"] as? Int ?? 0
                    self.currentGameAciertos = dict["currentGameAciertos"] as? Int ?? 0
                    self.currentGameFallos = dict["currentGameFallos"] as? Int ?? 0
                    self.currentGamePuntuacion = dict["currentGamePuntuacion"] as? Int ?? 0
                    self.accumulatedPuntuacion = dict["accumulatedPuntuacion"] as? Int ?? 0
                    self.accumulatedAciertos = dict["accumulatedAciertos"] as? Int ?? 0
                    self.accumulatedFallos = dict["accumulatedFallos"] as? Int ?? 0
                    self.positionInLeaderboard = dict["positionInLeaderboard"] as? Int ?? 0
                }
            }
        }
    }
}
