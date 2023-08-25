import SwiftUI
struct RegistrarUsuario: View {
    @StateObject private var viewModel = RegistrarUsuarioViewModel()
        @Environment(\.presentationMode) var presentationMode
        @State private var shouldNavigateToProfile: Bool = false  
        @State private var goToMenuModoCompeticion: Bool = false
    
    let userViewModelInstance = UserViewModel()
    
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
                    
                    VStack {
                       
                        
                        NavigationLink("", destination: ProfileView(
                            userViewModel: userViewModelInstance,
                            leaderboardPosition: 1,
                            shouldNavigateToProfile: $viewModel.shouldNavigateToProfile,
                            dismissAction: {
                                viewModel.shouldNavigateToProfile = false
                            }
                        ), isActive: $viewModel.shouldNavigateToProfile).hidden()

                        
                        Button(action: {
                            print("Register Button Tapped")
                            viewModel.registerUser {
                                print("User Registered Callback")
                            }
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
                        
                        NavigationLink("", destination: MenuModoCompeticion(userId:"DummyuserId", userData: UserData(), viewModel: RegistrarUsuarioViewModel()), isActive: $goToMenuModoCompeticion).hidden()
                        
                        Button(action: {
                            print("Back Button Tapped")
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
                        .padding(.bottom, 10)
                    }
                    .padding(.horizontal, 40)
                    
                }
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
                .alert(isPresented: $viewModel.alert.showAlert) {
                    print("Alert Displayed with Message: \(viewModel.alert.message)")
                    return Alert(title: Text(viewModel.alert.title),
                                 message: Text(viewModel.alert.message),
                                 dismissButton: .default(Text("OK"), action: {
                                     viewModel.alert.primaryAction?()
                                 }))
                }

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
                    .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 2)
                    .textContentType(.name)
                
                SingleInputFieldView(text: $email, placeholder: "Email")
                    .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 2)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.none)
                    .textContentType(/*@START_MENU_TOKEN@*/.emailAddress/*@END_MENU_TOKEN@*/)
                
                
                SecureInputFieldView(text: $password, placeholder: "Contraseña")
                    .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 2)
                    .autocorrectionDisabled()
                    .textContentType(.password)
                
                SingleInputFieldView(text: $telefono, placeholder: "Teléfono")
                    .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 2)
                    .textContentType(.telephoneNumber)
                SingleInputFieldView(text: $barrio, placeholder: "Barrio")
                    .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 2)
                    .autocorrectionDisabled()
                SingleInputFieldView(text: $ciudad, placeholder: "Ciudad")
                    .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 2)
                    .autocorrectionDisabled()
                SingleInputFieldView(text: $pais, placeholder: "País")
                    .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 2)
                    .autocorrectionDisabled()
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
                .padding(.bottom, 1)
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
    
    
    struct RegistrarUsuario_Previews: PreviewProvider {
        static var previews: some View {
            RegistrarUsuario()
        }
    }
    
}
