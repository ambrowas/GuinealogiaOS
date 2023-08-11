import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDatabase

class CurrentUser: ObservableObject {
    static let shared = CurrentUser()
    private init() {}
    @Published var userId: String? = nil
}

struct IniciarSesion: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @Binding var loggedInUserName: String
    @Binding var showIniciarSesion: Bool
    @State private var userFullName: String = ""
    @State private var showingAlert = false
    @State private var navigateToMenu = false
    @State private var navigateToRegistrarUsuario = false
    @State private var errorMessage: String = ""
    @ObservedObject var currentUser = CurrentUser.shared
    @State private var showAlertLogoutSuccess = false
    @State private var showLoginSuccessAlert = false
    @State private var showIncorrectPasswordAlert = false
    @State private var showInvalidEmailAlert = false
    @State private var alertType: AlertType?
    @State private var showMenuModoCompeticion = false
    @State private var shouldShowMenuModoCompeticion = false
    @State private var navigateToMenuModoCompeticion: MenuModoCompeticionNavigation?
    @Environment(\.presentationMode) var presentationMode


    enum AlertType: Identifiable {
        case loginSuccess, incorrectPassword, invalidEmail, emptyFields

        var id: Int {
            switch self {
            case .loginSuccess:
                return 1
            case .incorrectPassword:
                return 2
            case .invalidEmail:
                return 3
            case .emptyFields:
                return 4
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("coolbackground")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 10) {
                    Image("logotrivial")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.top, -150)
                        .frame(width: 200, height: 150)
                    
                    Text(userFullName.isEmpty ? "Usuario Desconectado" : userFullName)
                        .foregroundColor(.black)
                        .font(.headline)
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                    
                    if userFullName.isEmpty {
                        TextField("Email", text: $email, onCommit: {
                            self.email = self.email.lowercased()
                        })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 300)
                        .keyboardType(.emailAddress)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black, lineWidth: 3)
                        )
                        
                        SecureField("Contraseña", text: $password, onCommit: {
                            self.password = self.password.lowercased()
                        })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 300)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black, lineWidth: 3)
                        )
                      
                        Button(action: {
                            loginUser()
                        }) {
                            Text("INICIAR SESION")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 300, height: 75)
                                .background(Color(hue: 0.315, saturation: 0.953, brightness: 0.335))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 3)
                                )
                        }
                        .alert(item: $alertType) { type in
                            switch type {
                            case .loginSuccess:
                                return Alert(
                                    title: Text("Exito"),
                                    message: Text("Usuario Conectado"),
                                    dismissButton: .default(Text("OK")) {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                )
                            case .incorrectPassword:
                                return Alert(
                                    title: Text("Error"),
                                    message: Text("La contraseña es incorrecta. Inténtalo otra vez."),
                                    dismissButton: .default(Text("OK")) {
                                        password = ""
                                        showMenuModoCompeticion = true
                                    }
                                )
                            case .invalidEmail:
                                return Alert(
                                    title: Text("Error"),
                                    message: Text("Este email es incorrecto o no existe. Intentalo otra vez o crea una nueva cuenta."),
                                    dismissButton: .default(Text("OK")) {
                                        email = "" // Clear email
                                    }
                                )
                            case .emptyFields:
                                return Alert(
                                    title: Text("Error"),
                                    message: Text("Introduce el email y la contraseña"),
                                    dismissButton: .default(Text("OK"))
                                )
                            }
                        }
                        
                        Button(action: {
                            navigateToRegistrarUsuario = true
                        }) {
                            Text("REGISTRAR NUEVO USUARIO")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 300, height: 75)
                                .background(Color(hue: 0.664, saturation: 0.935, brightness: 0.604))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 3)
                                )
                        }
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
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
                        .fullScreenCover(isPresented: $navigateToRegistrarUsuario) {
                            RegistrarUsuario()
                                .onDisappear{
                                    presentationMode.wrappedValue.dismiss()
                                }
                        }
                    } else {
                        Button(action: {
                            signOutUser()
                        }) {
                            Text("CERRAR SESION")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 300, height: 75)
                                .background(Color(hue: 0.664, saturation: 0.935, brightness: 0.604))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 3)
                                )
                        }
                        
                    }
                }
            }
            
        }
    }

    func loginUser() {
        if email.isEmpty || password.isEmpty {
            self.alertType = .emptyFields
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            guard let user = authResult?.user, error == nil else {
                if let error = error {
                    let errorCode = error.localizedDescription
                    self.errorMessage = self.getCustomErrorDescription(errorCode: errorCode)

                    switch errorCode {
                    case "The password is invalid or the user does not have a password.":
                        self.alertType = .incorrectPassword
                    case "There is no user record corresponding to this identifier. The user may have been deleted.",
                         "The email address is badly formatted.":
                        self.alertType = .invalidEmail
                    default:
                        self.alertType = nil
                    }
                }
                return
            }

            let userId = user.uid
            self.currentUser.userId = userId

            let ref = Database.database().reference().child("user").child(userId)
            ref.observeSingleEvent(of: .value) { snapshot in
                let value = snapshot.value as? NSDictionary
                let username = value?["userName"] as? String ?? ""
                self.loggedInUserName = username
                self.userFullName = username
                self.showMenuModoCompeticion = true
                self.alertType = .loginSuccess
            }
        }
    }

    func signOutUser() {
        do {
            try Auth.auth().signOut()
            loggedInUserName = ""
            userFullName = ""
            showAlertLogoutSuccess = true
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }

    func getCustomErrorDescription(errorCode: String) -> String {
        var customDescription = ""
        switch errorCode {
        case "The password is invalid or the user does not have a password.":
            customDescription = "La contraseña es incorrecta. Inténtalo otra vez."
        case "There is no user record corresponding to this identifier. The user may have been deleted.",
             "The email address is badly formatted.":
            customDescription = "Este email es incorrecto o no existe. Intentalo otra vez o crea una nueva cuenta."
        default:
            customDescription = "Ocurrió un error inesperado. Inténtalo otra vez."
        }
        return customDescription
    }
}

struct IniciarSesion_Previews: PreviewProvider {
    static var previews: some View {
        IniciarSesion(loggedInUserName: .constant(""), showIniciarSesion: .constant(false))
    }
}

