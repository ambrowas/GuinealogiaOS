import SwiftUI

struct RegistrarUsuario: View {
    @StateObject private var viewModel = RegistrarUsuarioViewModel()
    @State private var shouldNavigate: Bool = false
    @State private var userId: String = ""
    @State private var userData: UserData = UserData()
   

    

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
                        .padding(.top, -90)
                        .frame(width: 200, height: 150)

                    InputFieldsView(fullname: $viewModel.fullname,
                                    email: $viewModel.email,
                                    password: $viewModel.password,
                                    telefono: $viewModel.telefono,
                                    barrio: $viewModel.barrio,
                                    ciudad: $viewModel.ciudad,
                                    pais: $viewModel.pais)

                    Button(action: {
                        viewModel.registerUser()
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
                            userId: userId,
                            userData: UserData(),
                            viewModel: RegistrarUsuarioViewModel()
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
                    }
                    .alert(isPresented: $viewModel.showAlert) {
                        Alert(
                            title: Text(viewModel.alertType == .error ? "Error" : "Success"),
                            message: Text(viewModel.alertMessage),
                            dismissButton: .default(Text("OK"), action: {
                                viewModel.dismissAction?()
                                viewModel.dismissAction = nil // clear the action to avoid unintentional re-executions
                            })
                        )
                    }



                } // End of the main VStack
                .sheet(isPresented: $viewModel.shouldPresentProfile) {
                    Profile(
                        userViewModel: UserViewModel(),
                        leaderboardPosition: 1,
                        shouldNavigateToProfile: $viewModel.shouldPresentProfile,
                        dismissAction: {
                            viewModel.shouldPresentProfile = false
                        }
                    )
                } // Sheet modifier attached here
            }
        }
    }
}

struct RegistrarUsuario_Previews: PreviewProvider {
    static var previews: some View {
        RegistrarUsuario() // Removed userId parameter
    }
}
