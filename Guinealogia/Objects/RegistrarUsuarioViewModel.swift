import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth

// Structure for user data
struct UserDataRegister {
    var fullname: String
    var highestScore: Int
}


class RegistrarUsuarioViewModel: ObservableObject {
    // Published properties for the view binding
    @Published var fullname: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var telefono: String = ""
    @Published var barrio: String = ""
    @Published var ciudad: String = ""
    @Published var pais: String = ""
    @Published var alert: AlertModel = AlertModel()
    @Published var showAlert: Bool = false
    @Published var isUserRegistered = false
    @Published var userDataRegister: UserDataRegister = UserDataRegister(fullname: "", highestScore: 0)
    @Published var showProfile = false
    @Published var alertDismissed = false
    @Published var alertType: AlertType?
    @Published var isUserSuccessfullyRegistered = false
    @Published var shouldNavigateToProfile: Bool = false
    
    private let userService: UserService

    init(userService: UserService = UserService()) {
        self.userService = userService
    }

    // Alert types to distinguish between different alerts
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

  
    // Structure to handle alert display properties
    struct AlertModel {
        var showAlert: Bool = false
        var title: String = ""
        var message: String = ""
        var type: AlertType?
        var primaryAction: (() -> Void)? = nil
    }

    
    func registerUser(completion: @escaping () -> Void) {
        print("Starting registration...")

        // Field validation
        guard !fullname.isEmpty, !email.isEmpty, !password.isEmpty, !telefono.isEmpty, !barrio.isEmpty, !ciudad.isEmpty, !pais.isEmpty else {
            print("Some fields are empty.")
            displayAlert(message: "Por favor completa todos los campos", type: .error)
            return
        }

        guard isValidEmail(email) else {
            print("Email is not valid.")
            displayAlert(message: "Por favor ingrese un email válido", type: .error)
            return
        }

        guard password.count >= 6 else {
            print("Password is too short.")
            displayAlert(message: "La contraseña debe tener al menos 6 caracteres", type: .error)
            return
        }

        print("Attempting to create user...")
        // Use UserService to register the user
        return userService.createUser(email: email, password: password, fullname: fullname, telefono: telefono, barrio: barrio, ciudad: ciudad, pais: pais) { [weak self] result in
            switch result {
            case .success(let uid):
                print("User created with UID: \(uid)")
                DispatchQueue.main.async {
                    self?.alert.title = "Éxito"
                    self?.alert.message = "Usuario creado correctamente. Completa tu perfil agregando una foto."
                    self?.alert.primaryAction = {
                        
//                        print("Attempting to sign in user...")
                        // Assuming UserService will also handle signing in
                        self?.userService.signIn(email: self?.email ?? "", password: self?.password ?? "") { result in
                            switch result {
                            case .success:
                                print("User signed in successfully.")
                                // Navigate to profile after dismissing the alert
                                self?.shouldNavigateToProfile = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 60.5) {
                                    self?.isUserSuccessfullyRegistered = true
                                    completion()
                                }
                                return
                            case .failure:
                                print("User sign in failed.")
                                // Navigate to profile after dismissing the alert
                                self?.shouldNavigateToProfile = true
                                self?.displayAlert(message: "Error al iniciar sesión", type: .error)
                                return
                            }
                        }
                    }
                }
                self?.alert.showAlert = true
                return
            case .failure(let error):
                print("Error while registering: \(error.localizedDescription)")
                if error.localizedDescription.contains("email address is already in use") {
                    self?.displayAlert(message: "Este email ya está registrado", type: .error)
                } else {
                    self?.displayAlert(message: "Error en el registro", type: .error)
                }
                return
            }
        }
    }

    func displayAlert(message: String, type: AlertType) {
        print("Displaying alert of type \(type): \(message)")
        DispatchQueue.main.async {
            self.alert.title = type == .error ? "Error" : "Éxito"
            self.alert.message = message
            self.alertType = type
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

