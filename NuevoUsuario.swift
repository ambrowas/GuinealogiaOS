import SwiftUI

struct NuevoUsuario: View {
    @StateObject private var viewModel = NuevoUsuarioViewModel()
    @State private var shouldPresentProfile = false
    @State private var scale: CGFloat = 1.0
    @State private var glowColor = Color.blue
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var isShowingProfile = false // New state variable for the profile presentation
    @State private var isShowingMenuModoCompeticion = false
    @StateObject private var userData = UserData() // Create an instance of UserData
    @StateObject private var menuModoCompeticionViewModel = MenuModoCompeticionViewModel() //

    var body: some View {
        ZStack {
            Image("coolbackground")
                .resizable()
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 10) {
                Image("logotrivial")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 150)
                    .shadow(color: glowColor.opacity(0.8), radius: 10, x: 0.0, y: 0.0)
                    .scaleEffect(scale)
                    .animation(
                        Animation.easeInOut(duration: 1.3)
                            .repeatForever(autoreverses: true)
                    )
                    .onAppear {
                        scale = 1.01
                    }
                    .onReceive(timer) { _ in
                        switch glowColor {
                        case Color.blue:
                            glowColor = .green
                        case Color.green:
                            glowColor = .red
                        case Color.red:
                            glowColor = .white
                        default:
                            glowColor = .blue
                        }
                    }

                InputFieldsView(
                    fullname: $viewModel.fullname,
                    email: $viewModel.email,
                    password: $viewModel.password,
                    telefono: $viewModel.telefono,
                    barrio: $viewModel.barrio,
                    ciudad: $viewModel.ciudad,
                    pais: $viewModel.pais
                )

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
                .fullScreenCover(isPresented: $isShowingProfile) {
                    Profile(
                        shouldNavigateToProfile: .constant(true),
                        leaderboardPosition: 1,
                        dismissAction: {},
                        shouldPresentProfile: $shouldPresentProfile
                    )
                }
                .padding(.bottom, 5)

                Button(action: {
                    SoundManager.shared.playTransitionSound()
                    isShowingMenuModoCompeticion.toggle()
                }) {
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

                .fullScreenCover(isPresented: $isShowingMenuModoCompeticion) {
                               MenuModoCompeticion(userId: "DummyuserId", userData: userData, viewModel: menuModoCompeticionViewModel)
                           }

                .padding(.top, 2)
            }
       
        }
        .alert(item: $viewModel.alertaTipo) { alertaTipo in
            switch alertaTipo {
            case .exito(let message):
                return Alert(
                    title: Text("Éxito"),
                    message: Text(message),
                    dismissButton: .default(Text("OK"), action: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            SoundManager.shared.playTransitionSound()
                            isShowingProfile = true
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
    
    struct NuevoUsuario_Previews: PreviewProvider {
        static var previews: some View {
            NuevoUsuario()
        }
    }
}
