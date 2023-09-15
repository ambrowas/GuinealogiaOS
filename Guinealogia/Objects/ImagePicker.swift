    import SwiftUI
    import UIKit
    import FirebaseDatabase
    import FirebaseStorage
    import FirebaseFirestore
    import FirebaseAuth


struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    @Binding var showSuccessAlertImagePicker: Bool
    @Binding var alertMessage: String
    @Binding var currentAlertType: ProfileAlertType?
    
    

    
    let storageRef: StorageReference
    let ref: DatabaseReference
    
    init(selectedImage: Binding<UIImage?>, showSuccessAlertImagePicker: Binding<Bool>, alertMessage: Binding<String>, currentAlertType: Binding<ProfileAlertType?>, storageRef: StorageReference, ref: DatabaseReference) {
        self._selectedImage = selectedImage
        self._showSuccessAlertImagePicker = showSuccessAlertImagePicker  // initialize with the new binding
        self._alertMessage = alertMessage // initialize the alertMessage binding
        self._currentAlertType = currentAlertType // initialize the currentAlertType binding
        self.storageRef = storageRef
        self.ref = ref
    }


    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                parent.uploadImage(image: image)
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func uploadImage(image: UIImage) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: No user signed in")
            return
        }
        
        let profileImageService = ProfileImageService(storageRef: storageRef, ref: ref)
        profileImageService.uploadImage(image: image, userId: userId) { result in
            switch result {
            case .success(let downloadURL):
                self.updateUserProfileImage(downloadURL: downloadURL)
            case .failure(let error):
                print("Error uploading image: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateUserProfileImage(downloadURL: String) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: No user signed in")
            return
        }

        let userRef = ref.child("user").child(userID)

        userRef.updateChildValues(["profilePicture": downloadURL]) { (error, ref) in
            if let error = error {
                print("Error updating data: \(error)")
                DispatchQueue.main.async {
                    self.currentAlertType = .error("Failed to update profile image")
                }
            } else {
                print("Profile image updated successfully")
                DispatchQueue.main.async {
                    self.currentAlertType = .success("Foto de perfil actualizada")
                }
            }
        }
    }
}
 

