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
    @Published var regresarAlMenuModoCompeticion: Bool = false

    
    enum AlertType: Identifiable {
        
        case loginSuccess
        case incorrectPassword
        case invalidEmail
        case emptyFields
        case generalError
        
        var id: Int {
            switch self {
            case .loginSuccess:
                return 1
            case .incorrectPassword:
                return 2
            case .invalidEmail:
                return 3
            case .emptyFields:
                return 4
            case .generalError:
                return 5
            }
        }
    }
    
    func loginAndSetAlertType() {
        print("Email: \(email)") // Debug print
        print("Password: \(password)") // Debug print
        
        // Verify inputs first
        if email.isEmpty || password.isEmpty {
            alertType = .emptyFields
            return
        }
        
        // Try to login
        loginUser()
    }
    
    func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                self.alertType = self.getAlertTypeBasedOnError(errorCode: error.localizedDescription)
            } else if let user = authResult?.user {
                let userId = user.uid
                self.currentUser.userId = userId
                print("User \(userId) has logged in successfully with email: \(self.email)")
                
                // Fetch additional user data
                self.fetchCurrentUserData(userId: userId) {
                self.alertType = .loginSuccess
                self.regresarAlMenuModoCompeticion = true
                    
                }
            } else {
                self.alertType = .generalError
            }
        }
    }
    
    func getAlertTypeBasedOnError(errorCode: String) -> AlertType {
        switch errorCode {
        case "The password is invalid or the user does not have a password.":
            return .incorrectPassword
        case "There is no user record corresponding to this identifier. The user may have been deleted.",
            "The email address is badly formatted.":
            return .invalidEmail
        default:
            return .generalError
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
    
    func fetchCurrentUserData(userId: String, completion: @escaping () -> Void) {
        let ref = Database.database().reference().child("user").child(userId)
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? NSDictionary,
                  let fullname = value["fullname"] as? String else {
                print("No fullname data found for userId: \(userId)")
                return
            }
            self.loggedInUserName = fullname
            self.userFullName = fullname
            completion()
        }
    }
}
