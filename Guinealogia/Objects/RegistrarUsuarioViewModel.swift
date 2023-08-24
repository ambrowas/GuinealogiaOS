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
    @Published var alert: AlertModel = AlertModel()
    @Published var isUserRegistered = false
    @Published var userData: UserData = UserData(fullname: "", highestScore: 0)
    @Published var showProfile = false
    @Published var alertDismissed = false
    @Published var alertType: AlertType?
    @Published var isUserSuccessfullyRegistered = false
    @Published var shouldNavigateToProfile: Bool = false


    
    enum AlertType: Identifiable {
        case error
        case userCreated

        var id: Int {
            switch self {
            case .error:
                return 1
            case .userCreated:
                return 2
            }
        }
    }



    struct UserData {
        var fullname: String
        var highestScore: Int
    }
    
    struct AlertModel {
        var showAlert: Bool = false
        var title: String = ""
        var message: String = ""
        var type: AlertType?
        var primaryAction: (() -> Void)? = nil
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
        print("registerUser called")
        
    
       
        // Field validation
        guard !fullname.isEmpty, !email.isEmpty, !password.isEmpty, !telefono.isEmpty, !barrio.isEmpty, !ciudad.isEmpty, !pais.isEmpty else {
            displayAlert(message: "Por favor completa todos los campos", type: .error)
            return
        }

        guard isValidEmail(email) else {
            displayAlert(message: "Por favor ingrese un email válido", type: .error)
            return
        }

        guard password.count >= 6 else {
            displayAlert(message: "La contraseña debe tener al menos 6 caracteres", type: .error)
            return
        }

        // Firebase authentication process
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            print("createUser completed")
            
            if let error = error {
                if error.localizedDescription.contains("email address is already in use") {
                    self.displayAlert(message: "Este email ya está registrado", type: .error)
                } else {
                    self.displayAlert(message: "Error en el registro", type: .error)
                }
                return
            }
            
            guard let user = authResult?.user else { return }
            let uid = user.uid
            let userData = [
                "fullname": self.fullname,
                "email": self.email,
                "telefono": self.telefono,
                "barrio": self.barrio,
                "ciudad": self.ciudad,
                "pais": self.pais,
                "highestScore": 0
            ] as [String: Any]

            // Firebase database process
            Database.database().reference().child("user").child(uid).setValue(userData) { error, _ in
                if let error = error {
                    self.displayAlert(message: "Error al guardar datos del usuario", type: .error)
                    return
                }
                
                self.addAccumulatedValuesForNewUser(userId: uid)
                self.displayAlertAndNavigate(message: "Usuario creado. Completa tu perfil agregando una foto", type: .userCreated)
            
               
                Auth.auth().signIn(withEmail: self.email, password: self.password) { _, error in
                    if let error = error {
                        self.displayAlert(message: "Error al iniciar sesión", type: .error)
                        // Return here, so if there's an error, the success alert isn't shown.
                        return
                    }
                    
                    // Regardless of whether the sign-in is successful or not, display the success alert.
                   
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.isUserSuccessfullyRegistered = true
                        completion()
                    }
                }
            }
        }
    }

    func displayAlert(message: String, type: AlertType) {
        DispatchQueue.main.async {
            self.alert.title = type == .error ? "Error" : "Éxito"
            self.alert.message = message
            self.alertType = type
            self.alert.showAlert = true
        }
    }

    func displayAlertAndNavigate(message: String, type: AlertType) {
        DispatchQueue.main.async {
            self.alert.title = type == .error ? "Error" : "Éxito"
            self.alert.message = message
            self.alert.type = type
            self.alert.primaryAction = {
                // This closure will be executed when the alert is dismissed.
                self.shouldNavigateToProfile = true
            }
            self.alert.showAlert = true
        }
    }

    func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regex)
        return predicate.evaluate(with: email)
    }

    func addAccumulatedValuesForNewUser(userId: String) {
        let newUser: [String: Any] = [
            "accumulatedAciertos": 0,
            "accumulatedFallos": 0,
            "accumulatedPuntuacion": 0
        ]
        let dbRef = Database.database().reference()
        dbRef.child("user").child(userId).updateChildValues(newUser) { (error, dbRef) in
            if let error = error {
                print("Error adding accumulated values: \(error)")
            } else {
                print("Successfully added accumulated values")
            }
        }
    }
    
   

}
