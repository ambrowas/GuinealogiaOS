import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth

class RegistrarUsuarioViewModel: ObservableObject {
    @Published var fullname: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var telefono: String = ""
    @Published var barrio: String = ""
    @Published var ciudad: String = ""
    @Published var pais: String = ""
    @Published var alert = AlertStruct()
    @Published var isUserRegistered = false
    @Published var userData: UserData = UserData(fullname: "", highestScore: 0)
    @Published var showProfile = false
    
    
    
    struct UserData {
        var fullname: String
        var highestScore: Int
    }
    
    
    struct AlertStruct {
        var showAlert = false
        var alertMessage = ""
        var alertUsuarioCreado = false
    }
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
                    self.userData.fullname = fullname
                    self.userData.highestScore = highestScore
                }
            }
        }
    }
    
    func registerUser(completion: @escaping () -> Void) {
        guard !fullname.isEmpty, !email.isEmpty, !password.isEmpty, !telefono.isEmpty, !barrio.isEmpty, !ciudad.isEmpty, !pais.isEmpty else {
            DispatchQueue.main.async {
                self.alert.alertMessage = "Por favor completa todos los campos"
                self.alert.showAlert = true
            }
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                let errorMessage = error.localizedDescription
                DispatchQueue.main.async {
                    if errorMessage.contains("email address is already in use") {
                        self.alert.alertMessage = "Este email ya está registrado"
                    } else {
                        self.alert.alertMessage = "Error en el registro"
                    }
                    self.alert.showAlert = true
                }
            } else {
                // Registration successful
                if let user = authResult?.user {
                    let uid = user.uid
                    
                    // Store additional user data in the Realtime Database
                    let userData = ["fullname": self.fullname, "email": self.email, "telefono": self.telefono, "barrio": self.barrio, "ciudad": self.ciudad, "pais": self.pais, "highestScore": 0] as [String : Any]
                    Database.database().reference().child("user").child(uid).setValue(userData)
                    
                    DispatchQueue.main.async {
                        self.alert.alertUsuarioCreado = true
                        self.alert.showAlert = true // Set showAlert to true here as well
                        
                        self.fetchUserData(userId: uid)
                        completion()
                        
                        self.showProfile = true // Set showProfile to true after successful registration
                    }
                }
            }
        }
    }
}
