import SwiftUI

struct RegistrarUsuario: View {
    @StateObject private var viewModel = RegistrarUsuarioViewModel()
//    @State private var shouldNavigate: Bool = false
 //   @State private var userId: String = ""
//    @State private var userData: UserData = UserData()
//    @State private var shouldNavigateToProfile = false
//    @State private var alertMessage: String = ""
//    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false

    var body: some View {
        ZStack {
            Image("coolbackground")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 10) {
                Image("logotrivial")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.top, -90)
                    .frame(width: 200, height: 150)
//                
//                InputFieldsView(fullname: $viewModel.fullname,
//                                email: $viewModel.email,
//                                password: $viewModel.password,
//                                telefono: $viewModel.telefono,
//                                barrio: $viewModel.barrio,
//                                ciudad: $viewModel.ciudad,
//                                pais: $viewModel.pais)
//                
                Button(action: {
                    print("[UI] Register button tapped.")
                    viewModel.registerUser(
                            email: viewModel.email,
                            password: viewModel.password,
                            fullname: viewModel.fullname,
                            telefono: viewModel.telefono,
                            barrio: viewModel.barrio,
                            ciudad: viewModel.ciudad,
                            pais: viewModel.pais
                        )
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
                .padding(.bottom, 10)
                
                NavigationLink(
                    destination: MenuModoCompeticion(
                        userId: "DummyUserId",
                        userData: UserData(),
                        viewModel: NuevoUsuarioViewModel()
                    )
                ) {
                    Text("VOLVER")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 75)
                        .background(Color(hue: 1.0, saturation: 0.984, brightness: 0.699))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 3)
                        )
                        .onAppear {
                            viewModel.navigateToProfile = false
                        }
                }
            }
            
            NavigationLink(
                          destination: Profile(
                              shouldNavigateToProfile: Binding.constant(false), leaderboardPosition: 1,
                              dismissAction: {}
                          ),
                          isActive: $viewModel.navigateToProfile
                      ) {
                          EmptyView()
                      }
                      .onChange(of: viewModel.navigateToProfile) { newValue in
                          print("[UI] viewModel.navigateToProfile changed to: \(newValue)")
                      }
                  }
                  .alert(isPresented: $viewModel.showAlert) {
                      Alert(title: Text(viewModel.currentAlertType.title),
                            message: Text(viewModel.currentAlertMessage),
                            dismissButton: .default(Text("OK"), action: {
                          viewModel.resetAlert()
                      }))
                  }
                  .onChange(of: viewModel.showAlert) { newValue in
                      self.showAlert = newValue
                  }
                  }
              }

struct RegistrarUsuario_Previews: PreviewProvider {
    static var previews: some View {
        RegistrarUsuario()
    }
}

