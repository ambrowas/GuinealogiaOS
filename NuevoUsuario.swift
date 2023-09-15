import SwiftUI


struct NuevoUsuario: View {
    @StateObject private var viewModel = NuevoUsuarioViewModel()
    @State private var shouldPresentProfile = false
   
        
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
                    
                    InputFieldsView(fullname: $viewModel.fullname,
                                    email: $viewModel.email,
                                    password: $viewModel.password,
                                    telefono: $viewModel.telefono,
                                    barrio: $viewModel.barrio,
                                    ciudad: $viewModel.ciudad,
                                    pais: $viewModel.pais)
                    
                    Button(action: {
                        viewModel.crearUsuario()
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
                    .background(
                        NavigationLink(
                            "",
                            destination: Profile(
                                               shouldNavigateToProfile: .constant(true),
                                               leaderboardPosition: 1,
                                               dismissAction: {},
                                               shouldPresentProfile: $shouldPresentProfile
                            ),
                            isActive: $viewModel.navegarAlPerfil
                        )
                        .opacity(0)
                    )
                    .padding(.bottom,5)
                    
                    
                    NavigationLink(destination: MenuModoCompeticion(userId: "DummyuserId", userData: UserData(), viewModel: MenuModoCompeticionViewModel())) {
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
                    .padding(.top, 2)
                }
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
            }
        
                
                .alert(item: $viewModel.alertaTipo) { alertaTipo in
                    switch alertaTipo {
                    case .exito(let message):
                        return Alert(
                            title: Text("Éxito"),
                            message: Text(message),
                            dismissButton: .default(Text("OK"), action: {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    viewModel.navegarAlPerfil = true
                                }
                            })
                        )
                    case .error(let message):
                        return Alert(
                            title: Text("Error"),
                            message: Text(message),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
            }
           
        }
    
   
    struct NuevoUsuario_Previews: PreviewProvider {
        static var previews: some View {
            NuevoUsuario()
        }
    }
    

