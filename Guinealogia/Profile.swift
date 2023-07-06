import SwiftUI
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

struct ProfileView: View {
    @ObservedObject var userViewModel: UserViewModel
      @State private var profileImage: UIImage?
      @State private var shouldShowJugarModoCompeticion = false
      var storageRef = Storage.storage().reference(forURL: "gs://trivial-guineologia.appspot.com/images")
      var ref = Database.database().reference()
      @State private var isImagePickerDisplayed = false
      @State private var showAlert = false
      @State private var alertMessage = ""
      @State private var showSuccessAlert = false
      let leaderboardPosition: Int
      let dismissAction: () -> Void
      @State private var shouldShowMenuModoCompeticion = false
    
    init(userViewModel: UserViewModel, leaderboardPosition: Int, dismissAction: @escaping () -> Void) {
          self.userViewModel = userViewModel
          self.leaderboardPosition = leaderboardPosition
          self.dismissAction = dismissAction
      }
      
        

    
    var body: some View {
        NavigationView {
            ZStack {
                Image("coolbackground")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 10) {
                    if let profileImage = profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 150)
                            .border(Color.black, width: 3)
                    } else {
                        Image(systemName: "person.fill") // Use a system image for the placeholder
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 150)
                            .border(Color.black, width: 3)
                            .foregroundColor(.gray)
                            .onTapGesture {
                                self.isImagePickerDisplayed = true
                            }
                            .overlay(
                                VStack {
                                    Text("Foto de Perfil")
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                }
                            )
                            .alert(isPresented: $showSuccessAlert) {
                                Alert(title: Text("¡Foto de perfil actualizada!"), dismissButton: .default(Text("OK")))
                            }
                    }
                    Circle()
                        .stroke(Color.black, lineWidth: 2) // black border
                        .background(Circle().fill(Color(hue: 1.0, saturation: 0.984, brightness: 0.699))) // red circle
                        .frame(width: 100, height: 100)
                        .padding(.leading, 200)
                        .padding(.top, -50)
                        .overlay(
                            FlashingText(text: "\(userViewModel.positionInLeaderboard)", shouldFlash: true)
                                .foregroundColor(.white)
                                .font(.largeTitle)
                                .bold()
                                .padding(.leading, 200)
                                .padding(.top, -40)
                        )

                       

                    List {
                        TextRowView(title: "NOMBRE", value: "\(userViewModel.fullname)")
                        TextRowView(title: "EMAIL", value: "\(userViewModel.email)")
                        TextRowView(title: "TELEFONO", value: "\(userViewModel.telefono)")
                        TextRowView(title: "BARRIO", value: "\(userViewModel.barrio)")
                        TextRowView(title: "CIUDAD", value: "\(userViewModel.ciudad)")
                        TextRowView(title: "PAIS", value: "\(userViewModel.pais)")
                        TextRowView(title: "RECORD", value: "\(userViewModel.highestScore)")
                    }
                    .listStyle(PlainListStyle())
                    .frame(width: 300, height: 310)
                    .padding(.horizontal, 5)
                    .background(Color.white)
                    .cornerRadius(5)
                    
                    
                    Button(action: {
                        shouldShowMenuModoCompeticion = true
                    }) {
                        Text("VOLVER")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 300, height: 55)
                            .background(Color(hue: 1.0, saturation: 0.984, brightness: 0.699))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 3)
                            )
                    }
                    .padding(.top, 20)
                }
            }
        }
        .onAppear {
            fetchProfileData()
        }
        .sheet(isPresented: $isImagePickerDisplayed) {
            ImagePicker(selectedImage: $profileImage, showSuccessAlert: $showSuccessAlert, storageRef: storageRef, ref: ref)
        }
        .sheet(isPresented: $shouldShowMenuModoCompeticion) {
            MenuModoCompeticion(userId: "hardCodedUserId", userData: UserData(), viewModel: RegistrarUsuarioViewModel())
        }

    }
    
    private func fetchProfileData() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            // No user signed in
            return
        }
        
        let ref = Database.database().reference().child("user").child(currentUserID)
        
        ref.observeSingleEvent(of: .value) { snapshot in
            if let userData = snapshot.value as? [String: Any] {
                DispatchQueue.main.async {
                    userViewModel.fullname = userData["fullname"] as? String ?? ""
                    userViewModel.email = userData["email"] as? String ?? ""
                    userViewModel.telefono = userData["telefono"] as? String ?? ""
                    userViewModel.barrio = userData["barrio"] as? String ?? ""
                    userViewModel.ciudad = userData["ciudad"] as? String ?? ""
                    userViewModel.pais = userData["pais"] as? String ?? ""
                    userViewModel.highestScore = userData["highestScore"] as? Int ?? 0
                    userViewModel.positionInLeaderboard = userData["positionInLeaderboard"] as? Int ?? 0
                    userViewModel.profilePicture = userData["profilePicture"] as? String ?? ""
                    fetchProfileImage()
                }
            } else {
                // Error occurred or data not found
                print("Error fetching profile data from Realtime Database")
            }
        }
    }
    
    private func fetchProfileImage() {
        guard let url = URL(string: userViewModel.profilePicture) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async {
                self.profileImage = UIImage(data: data)
            }
        }.resume()
    }
    
    struct TextRowView: View {
        var title: String
        var value: String
        
        var body: some View {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .frame(maxHeight: .infinity)
                    .padding(.vertical, 4)
                
                Spacer()
                
                Text(value)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .frame(maxHeight: .infinity)
                    .padding(.vertical, 4)
            }
        }
    }
    
    struct ProfileView_Previews: PreviewProvider {
        static var previews: some View {
            ProfileView(userViewModel: UserViewModel(), leaderboardPosition: 1, dismissAction: {})

                
            }}
    }


