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
    @State private var navigateToMenuModoCompeticion: Bool = false
    @State private var errorMessage: String = ""
    @ObservedObject var currentUser = CurrentUser.shared
    @State private var showAlertLogoutSuccess = false
    @State private var showLoginSuccessAlert = false


    
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
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 300)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.black, lineWidth: 3)
                            )
                        
                        SecureField("Contraseña", text: $password)
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
                        .alert(isPresented: $showLoginSuccessAlert) {
                            Alert(
                                title: Text("Success"),
                                message: Text("Usuario Conectado"),
                                dismissButton: .default(Text("OK")) {
                                    // Replace the current user's name
                                    userFullName = UserDefaults.standard.string(forKey: "loggedInUserName") ?? ""
                                    // Navigate to MenuModoCompeticion after alert is dismissed
                                    self.navigateToMenuModoCompeticion = true
                                }
                            )
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
                        .sheet(isPresented: $navigateToRegistrarUsuario) {
                            RegistrarUsuario()
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
                                .background(Color(hue: 0.315, saturation: 0.953, brightness: 0.335))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 3)
                                )
                        }
                        .alert(isPresented: $showAlertLogoutSuccess) {
                                    Alert(title: Text("Usuario Desconectado"), dismissButton: .default(Text("OK")))
                                }

                    }
                    
                    NavigationLink(destination: MenuModoCompeticion(userId: "hardCodedUserId", userData: UserData(), viewModel: RegistrarUsuarioViewModel())) {
                        Text("VOLVER")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                            .frame(width: 300, height: 75)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 3)
                            )
                    }
                }
            }
        }
        .onAppear {
            checkLoginStatus()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        NavigationLink(destination: MenuModoCompeticion(userId: "hardCodedUserId", userData: UserData(), viewModel: RegistrarUsuarioViewModel()), isActive: $navigateToMenuModoCompeticion) {
            EmptyView()
        }
    }
    
    func checkLoginStatus() {
        if let user = Auth.auth().currentUser {
            let ref = Database.database().reference().child("user").child(user.uid)
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if let dict = snapshot.value as? [String: Any],
                   let fullname = dict["fullname"] as? String {
                    DispatchQueue.main.async {
                        self.userFullName = fullname
                    }
                }
            })
        }
    }
    
    func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            guard let user = authResult?.user, error == nil else {
                print(error?.localizedDescription)
                self.errorMessage = self.getCustomErrorDescription(errorCode: error?._code ?? 0)
                self.showingAlert = true
                return
            }

            // User logged in successfully. Now, save the user's data.
            UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
            UserDefaults.standard.set(user.email, forKey: "loggedInUserName")
            UserDefaults.standard.set(0, forKey: "highestScore")
            UserDefaults.standard.synchronize()

            // Fetch user data from Firebase and update UserDefaults
            fetchUserData(userId: user.uid)

            // Display success alert
            DispatchQueue.main.async {
                self.showLoginSuccessAlert = true
                // Delay navigation to allow the alert to be seen
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.navigateToMenuModoCompeticion = true
                }
            }
        }
    }

    
    
    func getCustomErrorDescription(errorCode: Int) -> String {
        switch errorCode {
        case AuthErrorCode.wrongPassword.rawValue:
            return "Contraseña incorrecta. Por favor, inténtalo de nuevo."
        case AuthErrorCode.invalidEmail.rawValue:
            return "Por favor, introduce una dirección de correo electrónico válida."
        case AuthErrorCode.userNotFound.rawValue:
            return "Usuario no encontrado. Por favor, registra una cuenta nueva."
        case AuthErrorCode.networkError.rawValue:
            return "Problema de conexión a la red."
        default:
            return "Error de inicio de sesión. Por favor, inténtalo de nuevo más tarde."
        }
    }
    
    func signOutUser() {
           do {
               try Auth.auth().signOut()
               
               // Clear user data from UserDefaults
               UserDefaults.standard.removeObject(forKey: "loggedInUserName")
               UserDefaults.standard.removeObject(forKey: "highestScore")
               UserDefaults.standard.removeObject(forKey: "isUserLoggedIn")
               
               // Set userFullName to an empty string and show logout success alert
               DispatchQueue.main.async {
                   self.userFullName = ""
                   self.showAlertLogoutSuccess = true
               }
           } catch let signOutError as NSError {
               print ("Error signing out: %@", signOutError)
           }
       }
    func fetchUserData(userId: String) {
        let ref = Database.database().reference().child("user").child(userId)
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? [String: Any],
               let fullname = dict["fullname"] as? String,
               let score = dict["score"] as? Int { // Assuming 'score' exists in your Firebase database
                DispatchQueue.main.async {
                    UserDefaults.standard.set(fullname, forKey: "loggedInUserName")
                    UserDefaults.standard.set(score, forKey: "highestScore")
                    UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                    // Update userFullName state
                    self.userFullName = fullname
                }
            }
        })
    }


    
    struct IniciarSesion_Previews: PreviewProvider {
        static var previews: some View {
            IniciarSesion(loggedInUserName: .constant(""), showIniciarSesion: .constant(false))
        }
    }
    
}
