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
    @ObservedObject var currentUser = CurrentUser.shared
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var registrarViewModel = NuevoUsuarioViewModel()
    @State private var isShowingNuevoUsuario = false
    @State private var goToMenuModoCompeticion: Bool = false
    
    

    
    
 
    
    var body: some View {
        NavigationView{
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
                        TextField("Email", text: $viewModel.email, onCommit: {
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
                        
                        SecureField("Contraseña", text: $viewModel.password, onCommit: {
                            
                        })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 300)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black, lineWidth: 3)
                        )
                       
                        
                        
                        Button(action: {
                            viewModel.loginAndSetAlertType()
                            
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
                        
                        .alert(item: $viewModel.alertType) { type in
                            switch type {
                            case .loginSuccess:
                                return Alert(title: Text("Exito"), message: Text("Usuario Conectado"), dismissButton: .default(Text("OK")) {
                                    goToMenuModoCompeticion = true
                                })
                                
                            case .incorrectPassword:
                                return Alert(title: Text("Error"), message: Text("Contraseña Incorrecta."), dismissButton: .default(Text("OK")))
                                
                            case .invalidEmail:
                                return Alert(title: Text("Error"), message: Text("Email Incorrecto."), dismissButton: .default(Text("OK")))
                                
                            case .emptyFields:
                                return Alert(title: Text("Error"), message: Text("Debe rellenar ambos campos."), dismissButton: .default(Text("OK")))
                                
                            case .generalError:
                                return Alert(title: Text("Error"), message: Text("Ha ocurrido un error."), dismissButton: .default(Text("OK")))
                            }
                        }
                        NavigationLink(destination: NuevoUsuario(), isActive: $isShowingNuevoUsuario) {
                            Button(action: {
                                isShowingNuevoUsuario = true
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
                        }


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
        }
        
    
    
    struct IniciarSesion_Previews: PreviewProvider {
        static var previews: some View {
            IniciarSesion(loggedInUserName: .constant(""), showIniciarSesion: .constant(false))
        }
    }

