    import SwiftUI
    import FirebaseDatabase
    import FirebaseStorage
    import FirebaseAuth

struct Profile: View {
    @ObservedObject var userViewModel: UserViewModel
    @StateObject var profileViewModel = ProfileViewModel.shared
    @State private var profileImage: UIImage?
    @State private var shouldShowJugarModoCompeticion = false
    var storageRef = Storage.storage().reference(forURL: "gs://trivial-guineologia.appspot.com/images")
    var ref = Database.database().reference()
    @State private var isImagePickerDisplayed = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showSuccessAlert = false
    @Binding var shouldNavigateToProfile: Bool  // <-- Add this line here
    let leaderboardPosition: Int
    let dismissAction: () -> Void
    @State private var shouldShowMenuModoCompeticion = false
    @State private var profileData: [(title: String, value: String)] = []
    @Environment(\.presentationMode) var presentationMode
    @State private var goToMenuModoCompeticion: Bool = false
    @State private var currentDestination: Destination = .menuModoCompeticion
    @State private var userData: UserData = UserData()

    
    
    enum Destination: Hashable {
        case menuModoCompeticion
        //... other cases
    }
    
    init(userViewModel: UserViewModel, leaderboardPosition: Int, shouldNavigateToProfile: Binding<Bool>, dismissAction: @escaping () -> Void) {
        self.userViewModel = userViewModel
        self.leaderboardPosition = leaderboardPosition
        self._shouldNavigateToProfile = shouldNavigateToProfile
        self.dismissAction = dismissAction
        print("ProfileView initialized")
    }
    
    func destinationView(for destination: Destination?, userData: Binding<UserData>, goToMenuCompeticion: Binding<Bool>) -> some View {
        switch destination {
        case .menuModoCompeticion:
            return AnyView(MenuModoCompeticion(
                userId: "DummyuserId",
                userData: UserData(),
                viewModel: RegistrarUsuarioViewModel()
            ))
        default:
            return AnyView(EmptyView())
        }
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
                                    .background(Color.white)
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
                            
                            
                            ScrollView {
                                VStack {
                                    TextRowView(title: "NOMBRE", value: "\(userViewModel.fullname)")
                                    TextRowView(title: "EMAIL", value: "\(userViewModel.email)")
                                    TextRowView(title: "TELEFONO", value: "\(userViewModel.telefono)")
                                    TextRowView(title: "BARRIO", value: "\(userViewModel.barrio)")
                                    TextRowView(title: "CIUDAD", value: "\(userViewModel.ciudad)")
                                    TextRowView(title: "PAIS", value: "\(userViewModel.pais)")
                                    TextRowView(title: "RECORD", value: "\(userViewModel.highestScore)")
                                    TextRowView(title: "PUNTUACION ACUMULADA", value: "\(userViewModel.accumulatedPuntuacion)")
                                    TextRowView(title: "ACIERTOS ACUMULADOS", value: "\(userViewModel.accumulatedAciertos)")
                                    TextRowView(title: "FALLOS ACUMULADOS", value: "\(userViewModel.accumulatedFallos)")
                                    
                                }
                            }
                            .frame(width: 300, height: 310)
                            .padding(.horizontal, 5)
                            
                            Button(action: {
                            self.currentDestination = .menuModoCompeticion
                             self.shouldShowMenuModoCompeticion = true
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
                            .fullScreenCover(isPresented: $shouldShowMenuModoCompeticion) {
                                MenuModoCompeticion(
                                    userId: "DummyuserId",
                                    userData: userData, // Assuming userData is of type UserData
                                    viewModel: RegistrarUsuarioViewModel()
                                )
                            }

                            .padding(.top, 40)
                        }
                    }
                }
                .onAppear {
                    print("ProfileView appeared")
                    ProfileViewModel.shared.fetchProfileData()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    print("ProfileView is being loaded due to app entering foreground!")
                }
                .sheet(isPresented: $isImagePickerDisplayed) {
                    ImagePicker(selectedImage: $profileImage, showSuccessAlert: $showSuccessAlert, storageRef: storageRef, ref: ref)
                    
                }
                .navigationBarBackButtonHidden(true)
                
                
            }
            
            
            
            
            struct TextRowView: View {
                var title: String
                var value: String
                var currency: String?
                
                init(title: String, value: String, currency: String? = nil) {
                    self.title = title
                    self.value = value
                    self.currency = currency
                }
                
                var body: some View {
                    HStack {
                        Text(title)
                            .bold()
                            .foregroundColor(Color.gray)
                        Spacer()
                        Text(currency == nil ? value : "\(value) \(currency!)")
                            .foregroundColor(Color.blue)
                            .bold()
                    }
                    .padding(.vertical, 1)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            
            struct ProfileView_Previews: PreviewProvider {
                // Dummy binding for the preview
                @State static var dummyShouldNavigateToProfile = false
                
                static var previews: some View {
                    Profile(
                        userViewModel: UserViewModel(),
                        leaderboardPosition: 1,
                        shouldNavigateToProfile: $dummyShouldNavigateToProfile,
                        dismissAction: {}
                    )
                }
            }
        }
        

