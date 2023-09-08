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

    private var ref = Database.database().reference()
    private var storageRef = Storage.storage().reference(forURL: "gs://trivial-guineologia.appspot.com/images")

    func fetchProfileData() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("Failed to fetch current user ID")
            return
        }

        let userRef = ref.child("user").child(currentUserID)
        userRef.observeSingleEvent(of: .value) { [weak self] (snapshot, errorString) in
            guard let self = self else { return }
            if let userData = snapshot.value as? [String: Any] {
                self.fullname = userData["fullname"] as? String ?? ""
                self.email = userData["email"] as? String ?? ""
                self.telefono = userData["telefono"] as? String ?? ""
                self.barrio = userData["barrio"] as? String ?? ""
                self.ciudad = userData["ciudad"] as? String ?? ""
                self.pais = userData["pais"] as? String ?? ""
                self.highestScore = userData["highestScore"] as? Int ?? 0
                self.positionInLeaderboard = userData["positionInLeaderboard"] as? Int ?? 0
                self.accumulatedPuntuacion = userData["accumulatedPuntuacion"] as? Int ?? 0
                self.accumulatedAciertos = userData["accumulatedAciertos"] as? Int ?? 0
                self.accumulatedFallos = userData["accumulatedFallos"] as? Int ?? 0
                if let profilePictureURL = userData["profilePicture"] as? String {
                    self.fetchImageFromFirebaseStorage(path: profilePictureURL)
                }
            } else {
                print("Error fetching profile data from Realtime Database")
            }
        }
    }

    func fetchImageFromFirebaseStorage(path: String) {
        let imageRef = storageRef.child(path)
        imageRef.getData(maxSize: 1 * 1024 * 1024) { [weak self] data, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching image from Firebase Storage: \(error.localizedDescription)")
            } else if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImage = image
                }
            }
        }
    }
    
    func storeProfileImage(image: UIImage, completion: @escaping (Bool) -> Void) {
        guard let data = image.jpegData(compressionQuality: 1.0) else {
            completion(false)
            return
        }
        let imageRef = storageRef.child("path/to/image.jpg")
        imageRef.putData(data, metadata: nil) { _, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}

