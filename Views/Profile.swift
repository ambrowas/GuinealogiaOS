import SwiftUI
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import UIKit
import Combine



struct Profile: View {
    @StateObject var profileViewModel = ProfileViewModel.shared
    @State private var isImagePickerDisplayed = false
    @State private var showAlert: Bool = false
    @State private var showGestionarSesionView: Bool = false
    @State private var showMenuPrincipalView: Bool = false
    @State private var showMenuModoCompeticion: Bool = false
    @State private var showSuccessAlertImagePicker = false
    private let storageRef = Storage.storage().reference()
    private let ref = Database.database().reference()
    @State private var showCambiodeFotoAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var currentAlertType: AlertType? = nil
    
    
    
    @Environment(\.presentationMode) var presentationMode
    
    var alertTypeBinding: Binding<Bool> {
        Binding<Bool>(
            get: {
                switch profileViewModel.alertType {
                case .deleteConfirmation, .deletionSuccess, .deletionFailure,  .imageChangeSuccess, .imageChangeError(_), .volveratras:
                    return true
                case .none:
                    return false
                }
            },
            set: { newValue in
                if !newValue {
                    profileViewModel.alertType = .none
                }
            }
        )
    }
    
    

    var body: some View {
        ZStack {
            Image("tresy")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 10) {
                ZStack(alignment: .bottomLeading) {
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
                            .overlay(
                                VStack {
                                    Text("Foto de Perfil")
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                }
                            )
                    }

                    glowingMedalView(for: profileViewModel.positionInLeaderboard)
                          .offset(x: -10, y: 10)
                  }
                  .contentShape(Rectangle()) // 🔹 Makes entire ZStack tappable
                  .onTapGesture {
                      SoundManager.shared.playPick()
                      isImagePickerDisplayed = true
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
 
                ProfileInfoTable(profileViewModel: profileViewModel)
                    .padding(.horizontal, 3)
                    .id(profileViewModel.refreshID)
                
                Button(action: {
                    if profileViewModel.profileImage == nil {
                        // If no profile picture is set, prompt the user with the alert
                        profileViewModel.alertType = .volveratras
                        showAlert = true
                    } else {
                        // If a profile picture is set, directly navigate to the desired view
                        SoundManager.shared.playTransitionSound()
                        showMenuModoCompeticion = true
                    }
                }) {
                    Text("VOLVER")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(width: 300, height: 55)
                        .background(Color.pastelSilver)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 3)
                        )
                }
                
                Button(action: {
                   
                    profileViewModel.alertType = .deleteConfirmation
                    showAlert = true
                }) {
                    Text("BORRAR USUARIO")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(width: 300, height: 55)
                        .background(Color(hue: 1.0, saturation: 0.984, brightness: 0.699))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 3)
                        )
                }
                
                .alert(item: $profileViewModel.alertType) { alertType in
                    switch alertType {
                    case .deleteConfirmation:
                        SoundManager.shared.playNo()
                        return Alert(
                            title: Text("Confirmación"),
                            message: Text("¿Seguro de que quieres borrar esta cuenta? Esta acción no se puede deshacer."),
                            primaryButton: .destructive(Text("Borrar")) {
                                
                                profileViewModel.deleteUserAndNotify()
                            },
                            secondaryButton: .cancel()
                        )
                    case .deletionSuccess:
                        SoundManager.shared.playMagic()
                        return Alert(
                            title: Text("Usuario Borrado"),
                            message: Text("La cuenta y los datos serán borrados antes de 48 horas"),
                            dismissButton: .default(Text("OK")){
                                SoundManager.shared.playTransitionSound()
                                showMenuPrincipalView = true
                            }
                        )
                        
                    case .deletionFailure(let errorMessage):
                        SoundManager.shared.playError()
                        return Alert(
                            title: Text("Error"),
                            message: Text("Reinicia la sesión para poder borrar la cuenta"),
                            dismissButton: .default(Text("OK")){
                                SoundManager.shared.playTransitionSound()
                                showGestionarSesionView = true
                            }
                        )
                        
                    case .imageChangeSuccess:
                        SoundManager.shared.playMagic()
                        return Alert(
                            title: Text("Exito"),
                            message: Text("¡Foto de pefilf actualizada!"),
                            dismissButton: .default(Text("OK")){
                                SoundManager.shared.playTransitionSound()
                                showMenuModoCompeticion = true
                            }
                        )
                    case .imageChangeError(let errorMessage):
                        SoundManager.shared.playError()
                        return Alert(
                            title: Text("Error"),
                            message: Text(errorMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    case .volveratras:
                        SoundManager.shared.playNo()
                        return Alert(
                            title: Text(""),
                            message: Text("¿Seguro que quieres volver sin poner una foto?"),
                            primaryButton: .default(Text("OK")){
                                SoundManager.shared.playTransitionSound()
                                showMenuModoCompeticion = true
                            },
                            secondaryButton: .cancel()
                            
                            
                        )
                        
                    }
                }
            }
            .fullScreenCover(isPresented: $showGestionarSesionView) {
                GestionarSesion() // Assuming GestionarSesion is a View you have defined
            }
            
            .fullScreenCover(isPresented: $showMenuPrincipalView) {
                MenuPrincipal(player: .constant(nil))
            }
            .fullScreenCover(isPresented: $showMenuModoCompeticion) {
                MenuModoCompeticion(userId: "DummyuserId", userData: UserData(), viewModel: MenuModoCompeticionViewModel())
            }   
            
            .sheet(isPresented: $isImagePickerDisplayed) {
                ImagePicker(
                    profileViewModel: profileViewModel,
                    selectedImage: $profileViewModel.profileImage,
                    storageRef: Storage.storage().reference(),
                    ref: Database.database().reference()
                )
            }
            
            .onChange(of: profileViewModel.alertType) { alertType in
                switch alertType {
                case .imageChangeSuccess, .imageChangeError(_):
                    // No action is needed here as the alert will be shown based on the alertType value
                    break
                default:
                    break
                }
            }
            
            
            .onAppear {
                print("👁 Profile view appeared, fetching profile data.")
                  profileViewModel.fetchProfileData()
            }
            .overlay(
                Group {
                    if profileViewModel.isLoading {
                        ProgressView("Cargando perfil...")
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                }
            )
        }
    }
    
    @ViewBuilder
    func glowingMedalView(for position: Int) -> some View {
        switch position {
        case 1:
            Image("medallaoro")
                .resizable()
                .frame(width: 40, height: 40)
                .glowingMedalEffect(for: .oro)
        case 2:
            Image("medallaplata")
                .resizable()
                .frame(width: 40, height: 40)
                .glowingMedalEffect(for: .plata)
        case 3:
            Image("medallabronce")
                .resizable()
                .frame(width: 40, height: 40)
                .glowingMedalEffect(for: .bronce)
        default:
            EmptyView() // <-- display nothing
        }
    }
    
    struct ProfileInfoTable: View {
        let profileViewModel: ProfileViewModel // or however it's passed in

        var body: some View {
            VStack(spacing: 0) {
                TableStyleTextRowView(title: "NOMBRE:", content: profileViewModel.fullname)
                Divider().background(Color.black)
                TableStyleTextRowView(title: "EMAIL:", content: profileViewModel.email)
                Divider().background(Color.black)
                TableStyleTextRowView(title: "TELEFONO:", content: profileViewModel.telefono)
                Divider().background(Color.black)
                TableStyleTextRowView(title: "CIUDAD:", content: profileViewModel.ciudad)
                Divider().background(Color.black)
                TableStyleTextRowView(title: "PAIS:", content: profileViewModel.pais)
                Divider().background(Color.black)
                TableStyleTextRowView(title: "RECORD:", content: "\(profileViewModel.highestScore)")
                Divider().background(Color.black)
                TableStyleTextRowView(title: "PUNTUACIÓN ACUMULADA:", content: "\(profileViewModel.accumulatedPuntuacion)")
                Divider().background(Color.black)
                TableStyleTextRowView(title: "ACIERTOS ACUMULADOS:", content: "\(profileViewModel.accumulatedAciertos)")
                Divider().background(Color.black)
                TableStyleTextRowView(title: "FALLOS ACUMULADOS:", content: "\(profileViewModel.accumulatedFallos)")
            }
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 2)
            )
            .frame(width: 300)
        }
    }
        
    struct TableStyleTextRowView: View {
        let title: String
        let content: String
        
        var body: some View {
            HStack {
                Text(title)
                    .font(.custom("MarkerFelt-Thin", size: 14))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(content)
                    .font(.custom("MarkerFelt-Thin", size: 14))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(Color.white)
        }
    }
        struct Profile_Previews: PreviewProvider {
            static var previews: some View {
                Profile()
            }
        }
        
    }

