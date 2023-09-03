import Combine
import Firebase
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
    @Published var profilePicture: String = ""
    @Published var accumulatedPuntuacion: Int = 0
    @Published var accumulatedAciertos: Int = 0
    @Published var accumulatedFallos: Int = 0
    @Published var profileImage: UIImage?

    private var ref = Database.database().reference()
    private var storageRef = Storage.storage().reference(forURL: "gs://trivial-guineologia.appspot.com/images")

    func fetchProfileData() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("Failed to fetch current user ID")
            return
        }

        let userRef = ref.child("user").child(currentUserID)
        userRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            if let userData = snapshot.value as? [String: Any] {
                DispatchQueue.main.async {
                    self?.fullname = userData["fullname"] as? String ?? ""
                    self?.email = userData["email"] as? String ?? ""
                    self?.telefono = userData["telefono"] as? String ?? ""
                    self?.barrio = userData["barrio"] as? String ?? ""
                    self?.ciudad = userData["ciudad"] as? String ?? ""
                    self?.pais = userData["pais"] as? String ?? ""
                    self?.highestScore = userData["highestScore"] as? Int ?? 0
                    self?.positionInLeaderboard = userData["positionInLeaderboard"] as? Int ?? 0
                    self?.profilePicture = userData["profilePicture"] as? String ?? ""
                    self?.accumulatedPuntuacion = userData["accumulatedPuntuacion"] as? Int ?? 0
                    self?.accumulatedAciertos = userData["accumulatedAciertos"] as? Int ?? 0
                    self?.accumulatedFallos = userData["accumulatedFallos"] as? Int ?? 0
                    if let profilePictureURL = userData["profilePicture"] as? String {
                        self?.fetchProfileImage(from: profilePictureURL)
                    }
                }
            } else {
                print("Error fetching profile data from Realtime Database")
            }
        }
    }

    func fetchProfileImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Failed to create URL for profile picture")
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self?.profileImage = UIImage(data: data)
                print("Profile image fetched and set successfully")
            }
        }.resume()
    }
}

