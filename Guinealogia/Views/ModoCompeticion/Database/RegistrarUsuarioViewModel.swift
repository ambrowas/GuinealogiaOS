import Foundation
import FirebaseAuth
import Firebase
import FirebaseDatabase
import Combine



    class RegistrarUsuarioViewModel: ObservableObject {
        // Published properties for the view binding
        @Published var fullname: String = ""
        @Published var email: String = ""
        @Published var password: String = ""
        @Published var telefono: String = ""
        @Published var barrio: String = ""
        @Published var ciudad: String = ""
        @Published var pais: String = ""
        @Published var showAlert: Bool = false
        @Published var alertMessage: String = ""
        @Published var alertType: AlertType = .error
        @Published var shouldPresentProfile: Bool = false
        @Published var navigateToMenuPrincipal: Bool = false
        @Published var navigateToProfile: Bool = false {
            didSet {
                if navigateToProfile {
                    print("navigateToProfile set to true. Attempting navigation...")
                } else {
                    print("navigateToProfile set to false. Not navigating.")
                }
            }
        }


        var dismissAction: (() -> Void)?
        
       
        func registerUser() {
            DispatchQueue.main.async {
                    self.showAlert = false
                    self.alertMessage = ""
                    self.alertType = .error
                }
            guard validateFields() else {
                return
            }

            self.createUser(email: email, password: password, fullname: fullname, telefono: telefono, barrio: barrio, ciudad: ciudad, pais: pais) {
                result in
              switch result {
              case .success(let uid):
               
//                    print("User registered successfully with UID: \(uid)")
//
                 self.addAccumulatedValuesForNewUser(userId: uid) { success in
                        if success {
                            self.signIn(email: self.email, password: self.password) { result in
                                switch result {
                                case .success:
                                    print("User signed in successfully post registration.")
                                
                                    self.displaySuccessAlert()   // Call the refactored method here
                                case .failure(let error):
                                    print("Error signing in: \(error.localizedDescription)")
                                    self.displayAlert(message: "Error al iniciar sesión: \(error.localizedDescription)", type: .error)
                                }
                            }
                        } else {
                            print("Error: Couldn't add accumulated values for new user")
                        }
                   }
//
             case .failure(let error):
//                    print("Error registering user: \(error.localizedDescription)")
                   self.displayAlert(message: "Error registrando al usuario: \(error.localizedDescription)", type: .error)
            }
            }
        }


        func createUser(email: String, password: String, fullname: String, telefono: String, barrio: String, ciudad: String, pais: String, completion: @escaping (Result<String, Error>) -> Void) {
            print("Attempting to create user with email: \(email)")
            
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    print("Error creating user: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let user = authResult?.user else {
                    print("Unknown error: User data not available after creation.")
                    completion(.failure(NSError(domain: "AuthService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
                    return
                }
                
                let uid = user.uid
                print("User created successfully with UID: \(uid)")
                
                let userData = [
                    "fullname": fullname,
                    "email": email,
                    "telefono": telefono,
                    "barrio": barrio,
                    "ciudad": ciudad,
                    "pais": pais,
                    "highestScore": 0
                ] as [String: Any]
                
                print("Attempting to set user data in database...")
                
                Database.database().reference().child("user").child(uid).setValue(userData) { error, _ in
                    if let error = error {
                        print("Error setting user data in database: \(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        print("User data set successfully in database.")
                        completion(.success(uid))
                    }
                }
            }
        }
        
        func validateFields() -> Bool {
            // Check if any field is empty
            guard !fullname.isEmpty, !email.isEmpty, !password.isEmpty, !telefono.isEmpty, !barrio.isEmpty, !ciudad.isEmpty, !pais.isEmpty else {
                print("Some fields are empty.")
                displayAlert(message: "Por favor completa todos los campos", type: .error)
                return false
            }
            
            // Check if the email is valid directly within the guard statement
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
            guard emailPredicate.evaluate(with: email) else {
                print("Email is not valid.")
                displayAlert(message: "Por favor ingrese un email válido", type: .error)
                return false
            }

            // Check if the password length is sufficient
            guard password.count >= 6 else {
                print("Password is too short.")
                displayAlert(message: "La contraseña debe tener al menos 6 caracteres", type: .error)
                return false
            }

            // Check if the phone number contains only digits
            let digitSet = CharacterSet.decimalDigits
            guard telefono.rangeOfCharacter(from: digitSet.inverted) == nil else {
                print("Telefono contains non-digit characters.")
                displayAlert(message: "El número de teléfono solo debe contener dígitos", type: .error)
                return false
            }
            
            // If all validations passed
            return true
        }
        
        func signInAndNavigate() {
            print("Starting sign-in and navigate sequence...")
            self.signIn(email: email, password: password) { [weak self] result in
                switch result {
                case .success:
                    print("Signed in successfully!")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self?.shouldPresentProfile = true
                        print("Profile sheet should be presented now!")
                    }
                case .failure(let error):
                    print("Error signing in: \(error.localizedDescription)")
                    self?.displayAlert(message: "Error al iniciar sesión: \(error.localizedDescription)", type: .error)
                }
            }

        }
        
        func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
            print("Attempting to sign in with email: \(email)")
            
            Auth.auth().signIn(withEmail: email, password: password) { _, error in
                if let error = error {
                    print("Error signing in: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    print("Signed in successfully with email: \(email)")
                    completion(.success(()))
                }
            }
        }
        
        func addAccumulatedValuesForNewUser(userId: String, completion: @escaping (Bool) -> Void) {
            let newUser: [String: Any] = [
                "accumulatedAciertos": 0,
                "accumulatedFallos": 0,
                "accumulatedPuntuacion": 0
            ]
            
            let dbRef = Database.database().reference()
            dbRef.child("user").child(userId).updateChildValues(newUser) { (error, dbRef) in
                if let error = error {
                    print("Error adding accumulated values: \(error)")
                    self.displayAlert(message: "Error agregando valores acumulados: \(error.localizedDescription)", type: .error)
                    completion(false)
                } else {
                    print("Successfully added accumulated values")
                    completion(true)
                }
            }
        }
        

        func displayAlert(message: String, type: AlertType, dismissAction: (() -> Void)? = nil) {
            print("Attempting to display alert with message: \(message) and type: \(type)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                print("Setting alert properties for display...")
                
                self.alertMessage = message
                self.alertType = type
                self.showAlert = true
                self.dismissAction = dismissAction
                
                print("Alert properties set. showAlert is \(self.showAlert)")
            }
        }

        func displaySuccessAlert() {
            print("Inside displaySuccessAlert function...")

            self.displayAlert(message: "¡Usuario creado! Completa tu perfil agregando una foto", type: .success) {
                print("Alert dismiss action triggered!")
                self.dismissAction = self.handleNavigation 
            }
        }


        func handleNavigation() {
            // Logic to navigate to profile
          //  self.navigateToProfile = true
            self.navigateToMenuPrincipal = true
            print("Just set navigateToProfile to true")
        }
        
        
        enum AlertType {
            case error
            case success
        }
    }
