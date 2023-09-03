import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDatabase



class MenuModoCompeticionViewModel: ObservableObject {
    
    @Published var userFullName = ""
    @Published var highestScore = 0
    @Published var currentGameFallos = 0
    @Published var alertMessage = ""
    @Published var showAlert = false
    @Published var colorIndex: Int = 0
    @Published var showCheckCodigo: Bool = false
    @Published var jugarModoCompeticionActive: Bool = false
    @Published var goToMenuPrincipal: Bool = false
    @Published var showIniciarSesion: Bool = false
    
    
    
    var showAlertJugar = false
    var showAlertClasificacion = false
    var showAlertPerfil = false
    var showClasificacion = false
    var showProfile = false
    var shouldPresentGameOver: Bool = false
    var shouldPresentResultado: Bool = false
    var shouldNavigateToProfile: Bool = false
    
    
    
    

    func fetchCurrentUserData() {
    print("Fetching current user data...")
    if let user = Auth.auth().currentUser {
        print("User found: \(user.uid)")
        let ref = Database.database().reference().child("user").child(user.uid)
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? [String: Any],
                
                let fullname = dict["fullname"] as? String,
                let highestScore = dict["highestScore"] as? Int {
                let currentGameFallos = dict["currentGameFallos"] as? Int ?? 0
                
                DispatchQueue.main.async {
                    self.userFullName = fullname
                    self.highestScore = highestScore
                    self.currentGameFallos = currentGameFallos
                    
                    // Print fetched values
                    print("Fetched User Fullname: \(self.userFullName)")
                    print("Fetched Highest Score: \(self.highestScore)")
                    print("Fetched Current Game Fallos: \(self.currentGameFallos)")
                }
            } else {
                // Print an error message if snapshot could not be cast to [String: Any]
                print("Error: Snapshot could not be cast to [String: Any]")
            }
        }) { error in
            // Print an error if Firebase could not fetch the data
            print("Error fetching user data from Firebase: \(error.localizedDescription)")
        }
    } else {
        // No user is logged in
        self.userFullName = ""
        self.highestScore = 0
        self.currentGameFallos = 0
        
        // Print a message saying no user is logged in
        print("No user is logged in")
    }
}

    func validateCurrentGameFallos() -> Bool {
        return currentGameFallos >= 5
    }

    func getFlashingColor() -> Color {
       let colors: [Color] = [.red, .blue, .green, .white]
       return colors[colorIndex]
   }

    func startFlashing() {
       let flashingColors: [Color] = [.red, .blue, .green, .white]

       let flashingAnimation = Animation
           .linear(duration: 0.5)
           .repeatForever(autoreverses: true)

       withAnimation(flashingAnimation) {
           colorIndex = 0
       }

       for (index, _) in flashingColors.enumerated() {
           DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
               withAnimation(flashingAnimation) {
                   self.colorIndex = index
               }
           }
       }
   }
    
    func handlePlayButtonJugar() {
           if Auth.auth().currentUser != nil {
               print("User is authenticated. Setting jugarModoCompeticionActive to true.")
               self.jugarModoCompeticionActive = true
           } else {
               print("No authenticated user found. Showing alert.")
               self.alertMessage = "Debes iniciar sesión para poder jugar."
               self.showAlert = true
           }
       }
    
    func handleClasificacionButtonPressed() {
            if Auth.auth().currentUser != nil {
                print("Authenticated user found. Setting showClasificacion to true.")
                self.showClasificacion = true
            } else {
                print("No authenticated user found. Showing alert for Clasificacion.")
                self.alertMessage = "Debes iniciar sesión para poder acceder a la clasificación."
                self.showAlert = true
            }
        }
    
    func handlePerfilButtonPressed() {
            if Auth.auth().currentUser != nil {
                self.showProfile = true
            } else {
                self.alertMessage = "Debes iniciar sesión para poder acceder a tu perfil."
                self.showAlert = true
            }
        }
    
    func handleButtonIniciarSession() {
        if userFullName.isEmpty {
            print("User full name is empty. Showing Iniciar Sesion.")
            self.showIniciarSesion = true
        } else {
            print("Trying to logout user...")
            do {
                try Auth.auth().signOut()
                userFullName = ""
                highestScore = 0
                currentGameFallos = 0
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
        }
    }
    
    func handleVolverButtonPressed() {
        goToMenuPrincipal = true
        }

   }

 
