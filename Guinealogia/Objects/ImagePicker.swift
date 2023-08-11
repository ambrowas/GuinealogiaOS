    import SwiftUI
    import UIKit
    import FirebaseDatabase
    import FirebaseStorage
    import FirebaseFirestore
    import FirebaseAuth


    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var selectedImage: UIImage?
        @Environment(\.presentationMode) private var presentationMode
        @Binding var showSuccessAlert: Bool

        let storageRef: StorageReference
        let ref: DatabaseReference

        init(selectedImage: Binding<UIImage?>, showSuccessAlert: Binding<Bool>, storageRef: StorageReference, ref: DatabaseReference) {
               self._selectedImage = selectedImage
               self._showSuccessAlert = showSuccessAlert  // initialize with the new binding
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
            // Convert the image to JPEG data
            guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }

            // Create a reference to the file you want to upload
            let imageRef = storageRef.child("profileImages/\(UUID().uuidString).jpg")

            // Upload the file to the path
            let uploadTask = imageRef.putData(imageData, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    print("Error uploading image: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                // You can also access the download URL after upload.
                imageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }

                    // Now you can save the URL to the user's profile in the database
                    self.updateUserProfileImage(downloadURL: downloadURL.absoluteString)
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
                   } else {
                       print("Foto de perfil actualizada")
                       DispatchQueue.main.async {
                           self.showSuccessAlert = true  // update the success alert variable to true
                       }
                   }
               }
           }
       }
    class ImageUploader: ObservableObject {
        let storageRef: StorageReference
        let ref: DatabaseReference

        init(storageRef: StorageReference, ref: DatabaseReference) {
            self.storageRef = storageRef
            self.ref = ref
        }

        func uploadImage(image: UIImage) {
            // your implementation here...
        }
    }

