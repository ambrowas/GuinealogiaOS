import SwiftUI

struct RegistrarUsuario: View {
    @StateObject private var viewModel = RegistrarUsuarioViewModel()
    @State private var showProfile = false 
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
                        .padding(.trailing, 10.0)
                        .frame(width: 200, height: 150)
                    InputFieldsView(fullname: $viewModel.fullname,
                                    email: $viewModel.email,
                                    password: $viewModel.password,
                                    telefono: $viewModel.telefono,
                                    barrio: $viewModel.barrio,
                                    ciudad: $viewModel.ciudad,
                                    pais: $viewModel.pais)
                    
                    ButtonsView(registerAction: {
                        viewModel.registerUser {
                            // Set the isUserRegistered property after successful registration
                            viewModel.isUserRegistered = true
                        }
                    })
                    
                }.padding(.top, 10)
            }
            .alert(isPresented: $viewModel.alert.showAlert) {
                        if viewModel.alert.alertUsuarioCreado {
                            return Alert(
                                title: Text("Usuario Creado"),
                                message: Text("Completa tu perfil agregando una foto"),
                                dismissButton: .default(Text("OK")) {
                                    self.showProfile = true
                                }
                            )
                        } else {
                            return Alert(title: Text("Error"),
                                         message: Text(viewModel.alert.alertMessage),
                                         dismissButton: .default(Text("OK")))
                        }
                    }
                }
                .sheet(isPresented: $showProfile) {
                    ProfileView(userViewModel: UserViewModel(), leaderboardPosition: 1, dismissAction: {
                        showProfile = false
                    })
                }
            }
        }
    
    struct InputFieldsView: View {
        @Binding var fullname: String
        @Binding var email: String
        @Binding var password: String
        @Binding var telefono: String
        @Binding var barrio: String
        @Binding var ciudad: String
        @Binding var pais: String
        
        var body: some View {
            VStack {
                SingleInputFieldView(text: $fullname, placeholder: "Nombre")
                SingleInputFieldView(text: $email, placeholder: "Email")
                SecureInputFieldView(text: $password, placeholder: "Contraseña")
                SingleInputFieldView(text: $telefono, placeholder: "Teléfono")
                SingleInputFieldView(text: $barrio, placeholder: "Barrio")
                SingleInputFieldView(text: $ciudad, placeholder: "Ciudad")
                SingleInputFieldView(text: $pais, placeholder: "País")
            }
            .padding(.horizontal, 40)
        }
    }
    
    struct SingleInputFieldView: View {
        @Binding var text: String
        var placeholder: String
        
        var body: some View {
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 10)
        }
    }
    
    struct SecureInputFieldView: View {
        @Binding var text: String
        var placeholder: String
        
        var body: some View {
            SecureField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 10)
        }
    }
    
    struct ButtonsView: View {
        var registerAction: () -> Void
        @State private var shouldShowMenuModoCompeticion = false
        
        var body: some View {
            VStack {
                Button(action: {
                    registerAction()
                }) {
                    Text("REGISTRAR")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 75)
                        .background(Color(hue: 0.69, saturation: 0.89, brightness: 0.706))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 3)
                        )
                }
                
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
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 40)
            .sheet(isPresented: $shouldShowMenuModoCompeticion) {
                MenuModoCompeticion(userId: "hardCodedUserId", userData: UserData(), viewModel: RegistrarUsuarioViewModel())
            }
        }
    }
    
    struct RegistrarUsuario_Previews: PreviewProvider {
        static var previews: some View {
            RegistrarUsuario()
        }
    }


