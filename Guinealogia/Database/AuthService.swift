import SwiftUI
import Firebase
class AuthService: ObservableObject {
    @Published var isUserLoggedIn: Bool = false
    var currentUser: FirebaseAuth.User? { // Use FirebaseAuth.User instead of just User
        return Auth.auth().currentUser
    }
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            self?.isUserLoggedIn = user != nil
        }
    }
    
    deinit {
        if let authStateDidChangeListenerHandle = authStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(authStateDidChangeListenerHandle)
        }
    }
    
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            // handle any errors
            if let error = error {
                print("Error logging in: \(error)")
            } else if let authResult = authResult {
                let ref = Database.database().reference().child("user").child(authResult.user.uid)
                ref.observeSingleEvent(of: .value, with: { snapshot in
                    if let dict = snapshot.value as? [String: Any],
                       let fullname = dict["fullname"] as? String,
                       let highestScore = dict["highestScore"] as? Int {
                        DispatchQueue.main.async {
                            UserDefaults.standard.set(fullname, forKey: "loggedInUserName")
                            UserDefaults.standard.set(highestScore, forKey: "highestScore")
                            // save other user data as needed
                        }
                    }
                })
            }
        }
    }

    func signOut() throws {
        do {
            try Auth.auth().signOut()
            self.isUserLoggedIn = false
        } catch let signOutError {
            print("Error occurred while signing out: \(signOutError.localizedDescription)")
            throw signOutError
        }
    }
}
