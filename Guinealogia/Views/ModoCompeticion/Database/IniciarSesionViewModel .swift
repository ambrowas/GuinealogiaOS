import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDatabase

class IniciarSesionViewModel: ObservableObject {
    
    @Published var userFullName: String = ""
    @Published var password: String = ""
    @Published var email: String = ""
    @Published var loggedInUserName: String = ""
    @Published var showAlertLogoutSuccess: Bool = false
    @Published var errorMessage: String = ""
    @Published var currentUser: CurrentUser = CurrentUser.shared
    @Published var showMenuModoCompeticion: Bool = false
    @Published var alertType: AlertType?
    
    enum AlertType: Identifiable {
        case userCreated, emptyFields, incorrectPassword, invalidEmail, loginSuccess, generalError
        
        var id: Int {
            switch self {
            case .userCreated:
                return 1
            case .emptyFields:
                return 2
            case .incorrectPassword:
                return 3
            case .invalidEmail:
                return 4
            case .loginSuccess:
                return 5
            case .generalError:
                return 6
            }
        }
    }
    
    func loginAndSetAlertType(completion: @escaping (AlertType?) -> Void) {
        loginUser {
            // Now this will be called after the loginUser logic is complete
            switch self.errorMessage {
            case "La contraseña es incorrecta. Inténtalo otra vez.":
                completion(.incorrectPassword)
            case "Este email es incorrecto o no existe. Intentalo otra vez o crea una nueva cuenta.":
                completion(.invalidEmail)
            case "Ocurrió un error inesperado. Inténtalo otra vez.":
                completion(.generalError)
            default:
                completion(self.userFullName.isEmpty ? .emptyFields : .loginSuccess)
            }
        }
    }
    
    
    func loginUser(completion: (() -> Void)? = nil) {
        if email.isEmpty || password.isEmpty {
            print("Email and password fields are empty.")
            self.alertType = .emptyFields
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            guard let user = authResult?.user, error == nil else {
                if let error = error {
                    print("Firebase sign-in error: \(error.localizedDescription)")
                    self.errorMessage = self.getCustomErrorDescription(errorCode: error.localizedDescription)
                    print("Custom error message: \(self.errorMessage)")
                    
                }
                return
            }
            
            let userId = user.uid
            self.currentUser.userId = userId
            
            self.fetchCurrentUserData(userId: userId) {
                self.showMenuModoCompeticion = true
            }
        }
    }
    
    func signOutUser() {
        print("signOutUser called.")
        do {
            try Auth.auth().signOut()
            loggedInUserName = ""
            userFullName = ""
            showAlertLogoutSuccess = true
            print("User signed out successfully.")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
    }
    
    func getCustomErrorDescription(errorCode: String) -> String {
        var customDescription = ""
        switch errorCode {
        case "The password is invalid or the user does not have a password.":
            customDescription = "La contraseña es incorrecta. Inténtalo otra vez."
        case "There is no user record corresponding to this identifier. The user may have been deleted.",
            "The email address is badly formatted.":
            customDescription = "Este email es incorrecto o no existe. Intentalo otra vez o crea una nueva cuenta."
        default:
            customDescription = "Ocurrió un error inesperado. Inténtalo otra vez."
        }
        return customDescription
    }
  
    func fetchCurrentUserData(userId: String, completion: @escaping () -> Void) {
        let ref = Database.database().reference().child("user").child(userId)
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? NSDictionary,
                  let username = value["userName"] as? String else {
                print("No user data found for userId: \(userId)")
                return
            }
            self.loggedInUserName = username
            self.userFullName = username
            completion()
        }
    }
    
    
    
}
