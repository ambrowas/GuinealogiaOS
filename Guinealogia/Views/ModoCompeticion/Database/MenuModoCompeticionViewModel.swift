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
    
    
    
    init() {
        fetchCurrentUserData()
    }
    func fetchCurrentUserData() {
        
        print("Fetching current user data...")
        
        // Initially, fetch data from UserDefaults
        self.userFullName = UserDefaults.standard.string(forKey: "fullname") ?? "Usuario Desconectado"
        self.highestScore = UserDefaults.standard.integer(forKey: "highestScore") // Fetching initial value as 0
        self.currentGameFallos = UserDefaults.standard.integer(forKey: "currentGameFallos") // Fetching initial value as 0
        
        guard let user = Auth.auth().currentUser else {
            print("No user is logged in")
            return
        }
        
        print("User found: \(user.uid)")
        
        let ref = Database.database().reference().child("user").child(user.uid)
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            // Fetch user details from Firebase and update UserDefaults with new values
            if let data = snapshot.value as? [String: Any] {
                self.userFullName = data["fullname"] as? String ?? "Usuario Desconectado"
                self.highestScore = data["highestScore"] as? Int ?? 0
                self.currentGameFallos = data["currentGameFallos"] as? Int ?? 0
                
                // Updating UserDefaults with fetched data
                UserDefaults.standard.set(self.userFullName, forKey: "fullname")
                UserDefaults.standard.set(self.highestScore, forKey: "highestScore")
                UserDefaults.standard.set(self.currentGameFallos, forKey: "currentGameFallos")
            }
        }) { error in
            print("Error fetching data: \(error.localizedDescription)")
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

 
