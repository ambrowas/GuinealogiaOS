    import SwiftUI
    import Firebase
    import FirebaseDatabase
    import FirebaseStorage
    import FirebaseAuth
    import UIKit

struct Profile: View {
    @StateObject var profileViewModel = ProfileViewModel.shared
    @State private var isImagePickerDisplayed = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showSuccessAlert = false
    @Binding var shouldNavigateToProfile: Bool
    let leaderboardPosition: Int
    let dismissAction: () -> Void
    @State private var shouldShowMenuModoCompeticion = false
    @State private var navigateToMenuModoCompeticion = false

    var body: some View {
        
            ZStack {
                Image("coolbackground")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 10) {
                    if let profileImage = profileViewModel.profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 150)
                            .border(Color.black, width: 3)
                            .background(Color.white)
                    } else {
                        Image(systemName: "person.fill")
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
                        .stroke(Color.black, lineWidth: 2)
                        .background(Circle().fill(Color(hue: 1.0, saturation: 0.984, brightness: 0.699)))
                        .frame(width: 100, height: 100)
                        .padding(.leading, 200)
                        .padding(.top, -50)
                        .overlay(
                            Text("\(profileViewModel.positionInLeaderboard)")
                                .foregroundColor(.white)
                                .font(.largeTitle)
                                .bold()
                                .padding(.leading, 200)
                                .padding(.top, -40)
                        )
                    
                    ScrollView {
                        VStack {
                            TextRowView(title: "NOMBRE:", content: profileViewModel.fullname)
                            TextRowView(title: "EMAIL:", content: profileViewModel.email)
                            TextRowView(title: "TELEFONO:", content: profileViewModel.telefono)
                            TextRowView(title: "CIUDAD:", content: profileViewModel.ciudad)
                            TextRowView(title: "PAIS:", content: profileViewModel.pais)
                            TextRowView(title: "RECORD:", content: "\(profileViewModel.highestScore)")
                            TextRowView(title: "PUNTUACION ACUMULADA:", content: "\(profileViewModel.accumulatedPuntuacion)")
                            TextRowView(title: "ACIERTOS ACUMULADOS:", content: "\(profileViewModel.accumulatedAciertos)")
                            TextRowView(title: "FALLOS ACUMULADOS:", content: "\(profileViewModel.accumulatedFallos)")
                        }
                    }
                    .frame(width: 300, height: 400)
                    .padding(.horizontal, 3)
                    
                    NavigationLink(destination: MenuModoCompeticion(userId: "DummyuserId", userData: UserData(), viewModel: NuevoUsuarioViewModel())) {
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
                    .padding(.top, 10)
                }
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
            }
        
           
            .sheet(isPresented: $isImagePickerDisplayed) {
                ImagePicker(
                    selectedImage: $profileViewModel.profileImage,
                    showSuccessAlertImagePicker: $showSuccessAlert,
                    storageRef: Storage.storage().reference(), // example reference; replace with the correct one if needed
                    ref: Database.database().reference()      // example reference; replace with the correct one if needed
                )
            }
            .alert(isPresented: $showAlert) {
                if showSuccessAlert {
                    return Alert(title: Text("Success"), message: Text("Image uploaded successfully!"), dismissButton: .default(Text("OK")))
                } else {
                    return Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
            .onAppear {
                print("Should navigate to profile: \(shouldNavigateToProfile)")
                profileViewModel.fetchProfileData()
            }
        }
    }

    struct TextRowView: View {
        let title: String
        let content: String
        
        var body: some View {
            HStack(alignment: .center, spacing: 10) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                    .frame(width: 120, alignment: .leading) // Adjust width as needed for proper alignment
                
                Text(content)
                    .font(.system(size: 14))
                    .padding(3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                Spacer()  // This pushes the content to the left
            }
            .padding([.leading, .trailing])
        }
    }


struct Profile_Previews: PreviewProvider {
    static var previews: some View {
        Profile(shouldNavigateToProfile: .constant(true), leaderboardPosition: 1, dismissAction: {})
    }
}
