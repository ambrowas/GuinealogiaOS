
import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth

class UserService {
    
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
    
    func fetchUserData(userId: String, completion: @escaping (Result<UserDataRegister, Error>) -> Void) {
        print("Attempting to fetch data for user with UID: \(userId)")
        
        let ref = Database.database().reference().child("user").child(userId)
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() {
                print("Error: User with UID: \(userId) not found.")
                completion(.failure(NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                return
            }
            
            if let dict = snapshot.value as? [String: Any],
               let fullname = dict["fullname"] as? String,
               let highestScore = dict["highestScore"] as? Int {
                print("User data fetched successfully.")
                let userData = UserDataRegister(fullname: fullname, highestScore: highestScore)
                completion(.success(userData))
            } else {
                print("Error parsing user data for UID: \(userId)")
                completion(.failure(NSError(domain: "UserService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Error parsing user data"])))
            }
        }) { error in
            print("Error fetching user data: \(error.localizedDescription)")
            completion(.failure(error))
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
}
