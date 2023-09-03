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
    @StateObject private var viewModel = IniciarSesionViewModel()
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
    @ObservedObject var registrarViewModel = RegistrarUsuarioViewModel()
    @State private var isShowingRegistrarUsuario = false
    @State private var goToMenuModoCompeticion: Bool = false
    
    
    
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
                Color.clear.onAppear(perform: {
                    print("View body is being redrawn.")
                })
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
                        .autocapitalization(.none)
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
                            viewModel.loginUser()
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
                            isShowingRegistrarUsuario = true
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
                        NavigationLink("", destination: MenuModoCompeticion(userId:"DummyuserId", userData: UserData(), viewModel: RegistrarUsuarioViewModel()), isActive: $goToMenuModoCompeticion).hidden()
                        
                        Button(action: {
                            goToMenuModoCompeticion = true
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
                        .fullScreenCover(isPresented: $isShowingRegistrarUsuario) {
                            RegistrarUsuario()
                                .onDisappear {
                                    presentationMode.wrappedValue.dismiss()
                                }
                        }
                    } else {
                        Button(action: {
                            viewModel.signOutUser()
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
                        .navigationBarHidden(true)
                        .navigationBarBackButtonHidden(true)
                        
                    }
                }
            }
            
        }
    }
    
    
    
    struct IniciarSesion_Previews: PreviewProvider {
        static var previews: some View {
            IniciarSesion(loggedInUserName: .constant(""), showIniciarSesion: .constant(false))
        }
    }
}
