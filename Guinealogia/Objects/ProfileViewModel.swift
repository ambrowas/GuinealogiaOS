import SwiftUI
import Firebase
import FirebaseDatabase
import FirebaseStorage

class ProfileViewModel: ObservableObject {
    static let shared = ProfileViewModel()
    
    private init() {}
    
    @Published var fullname: String = ""
    @Published var email: String = ""
    @Published var telefono: String = ""
    @Published var barrio: String = ""
    @Published var ciudad: String = ""
    @Published var pais: String = ""
    @Published var highestScore: Int = 0
    @Published var positionInLeaderboard: Int = 0
    @Published var profileImage: UIImage?
    @Published var accumulatedPuntuacion: Int = 0
    @Published var accumulatedAciertos: Int = 0
    @Published var accumulatedFallos: Int = 0
    @Published var profileFetchStatus: ProfileFetchStatus?
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var profileImageUpdateStatus: YourStatusType? = .none
    @Published var shouldNavigateToMenuModoCompeticion = false
    
    enum YourStatusType {
        case success
        case failure(String)
        case none
    }
    
    
    
    private var ref = Database.database().reference()
    private var storageRef = Storage.storage().reference(forURL: "gs://trivial-guineologia.appspot.com/images")
    
    private var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }
    
    enum ProfileFetchStatus {
        case success
        case failure(String)
        case noImage
        case none
    }

    
    func fetchProfileImage(url: String) {
        guard let url = URL(string: url) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Failed to fetch the profile image with error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.profileFetchStatus = .failure("Failed to fetch the profile image")
                }
                return
            }

            guard let data = data else {
                print("Failed to fetch data")
                DispatchQueue.main.async {
                    self.profileFetchStatus = .failure("Failed to fetch data")
                }
                return
            }

            guard let image = UIImage(data: data) else {
                print("Failed to convert data to image")
                DispatchQueue.main.async {
                    self.profileFetchStatus = .failure("Failed to convert data to image")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.profileImage = image
                self.profileFetchStatus = .success
                print("Successfully fetched and set the profile image")
            }
        }.resume()
    }

    
    
    func fetchProfileData() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("Failed to fetch current user ID")
            self.alertMessage = "Failed to fetch current user ID"
            self.showAlert = true
            return
        }
        
        let userRef = ref.child("user").child(currentUserID)
        userRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            if let userData = snapshot.value as? [String: Any] {
                DispatchQueue.main.async {
                    self.fullname = userData["fullname"] as? String ?? "Unknown"
                    self.email = userData["email"] as? String ?? "Unknown"
                    self.telefono = userData["telefono"] as? String ?? "Unknown"
                    self.barrio = userData["barrio"] as? String ?? "Unknown"
                    self.ciudad = userData["ciudad"] as? String ?? "Unknown"
                    self.pais = userData["pais"] as? String ?? "Unknown"
                    self.highestScore = userData["highestScore"] as? Int ?? 0
                    self.positionInLeaderboard = userData["positionInLeaderboard"] as? Int ?? 0
                    self.accumulatedPuntuacion = userData["accumulatedPuntuacion"] as? Int ?? 0
                    self.accumulatedAciertos = userData["accumulatedAciertos"] as? Int ?? 0
                    self.accumulatedFallos = userData["accumulatedFallos"] as? Int ?? 0
                    
                    if let profileImageURL = userData["profilePicture"] as? String, !profileImageURL.isEmpty {
                        self.fetchProfileImage(url: profileImageURL)
                    } else {
                        self.profileImage = nil
                        self.profileFetchStatus = .noImage
                    }
                }
                
                print("Successfully fetched and updated profile data")
            } else {
                print("Error fetching profile data from Realtime Database")
                self.alertMessage = "Error fetching profile data"
                self.showAlert = true
                self.profileFetchStatus = .failure("Error fetching profile data")
            }
        }
    }


    
}
