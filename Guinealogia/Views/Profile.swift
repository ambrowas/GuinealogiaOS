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


    @Environment(\.presentationMode) var presentationMode
    
    var alertTypeBinding: Binding<Bool> {
        Binding<Bool>(
            get: {
                switch profileViewModel.alertType {
                case .deleteConfirmation, .deletionSuccess, .deletionFailure:
                    return true
                case .none:
                    return false
                }
            },
            set: { newValue in
                if !newValue {
                    profileViewModel.alertType = nil
                }
            }
        )
    }

    
    var body: some View {
        ZStack {
            Image("coolbackground")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 10) {
                Group {
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
                }
                .onTapGesture {
                    self.isImagePickerDisplayed = true
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
                
                Button(action: {
                    SoundManager.shared.playTransitionSound()
                    presentationMode.wrappedValue.dismiss()
                    
                }) {
                    Text("VOLVER")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 55)
                        .background(Color(hue: 0.69, saturation: 0.89, brightness: 0.706))
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
                
                .alert(item: $profileViewModel.alertType) { alertType in
                    switch alertType {
                    case .deleteConfirmation:
                        return Alert(
                            title: Text("Confirmación"),
                            message: Text("¿Estás seguro de que quieres borrar esta cuenta? Esta acción no se puede deshacer."),
                            primaryButton: .destructive(Text("Borrar")) {
                                
                                profileViewModel.deleteUserAndNotify()
                            },
                            secondaryButton: .cancel()
                        )
                    case .deletionSuccess:
                        return Alert(
                            title: Text("Usuario Borrado"),
                            message: Text("La cuenta y los datos serán borrados antes de 48 horas"),
                            dismissButton: .default(Text("OK")){
                                SoundManager.shared.playTransitionSound()
                                showMenuPrincipalView = true
                            }
                        )
                        
                    case .deletionFailure(let errorMessage):
                        return Alert(
                            title: Text("Error"),
                            message: Text("Reinicia la sesión para poder borrar la cuenta"),
                            dismissButton: .default(Text("OK")){
                                SoundManager.shared.playTransitionSound()
                            showGestionarSesionView = true
                            }
                                )
                            }
                        }
                        .fullScreenCover(isPresented: $showGestionarSesionView) {
                            GestionarSesion() // Assuming GestionarSesion is a View you have defined
                        }
            }
            .fullScreenCover(isPresented: $showMenuPrincipalView) {
                MenuPrincipal(player: .constant(nil))
            }
                .onAppear {
                    profileViewModel.fetchProfileData()
                }
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
                    .foregroundColor(.black)
                
                Text(content)
                    .font(.system(size: 14))
                    .padding(3)
                    .foregroundColor(.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                Spacer()
            }
            .padding([.leading, .trailing])
            .environment(\.colorScheme, .light)
        }
    }
    
    struct Profile_Previews: PreviewProvider {
        static var previews: some View {
            Profile()
        }
    }

