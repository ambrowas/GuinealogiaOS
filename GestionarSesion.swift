import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDatabase

struct GestionarSesion: View {
    @StateObject var viewModel = GestionarSesionViewModel()
    @State private var correoelectronico: String = ""
    @State private var contrasena: String = ""
    @State private var navegarMenuModoCompeticion = false
    @State private var isShowingNuevoUsuario = false
    @State private var isShowingVolver = false // New state variable for VOLVER button
    @State private var scale: CGFloat = 1.0
    @State private var glowColor = Color.blue
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Image("tresy")
                .resizable()
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 10) {
                Image("logotrivial")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 150)
                    .shadow(color: glowColor.opacity(0.8), radius: 10, x: 0.0, y: 0.0)
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
                    .padding(.bottom, 10)

                TextField("Email", text: $correoelectronico, onCommit: {
                    self.correoelectronico = self.correoelectronico.lowercased()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 300)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.black, lineWidth: 3)
                )

                SecureField("Contraseña", text: $contrasena, onCommit: {})
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 300)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black, lineWidth: 3)
                    )
                    .padding(.bottom, 10)

                VStack(spacing: 10) {
                    Button(action: {
                       
                        viewModel.loginUsuario(correoElectronico: correoelectronico, contrasena: contrasena)
                    }) {
                        Text("INICIAR SESION")
                            .font(.custom("MarkerFelt-Thin", size: 16))
                            .foregroundColor(.black)
                            .padding()
                            .frame(width: 300, height: 75)
                            .background(Color.pastelSilver)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 3)
                            )
                    }

                    // Button to show NuevoUsuario view
                    Button(action: {
                        SoundManager.shared.playTransitionSound()
                        self.isShowingNuevoUsuario = true
                    }) {
                        Text("REGISTRAR NUEVO USUARIO")
                            .font(.custom("MarkerFelt-Thin", size: 16))
                            .foregroundColor(.black)
                            .padding()
                            .frame(width: 300, height: 75)
                            .background(Color.pastelSilver)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 3)
                            )
                    }
                    .fullScreenCover(isPresented: $isShowingNuevoUsuario) {
                        NuevoUsuario()
                    }

                    // Button to show VOLVER view
                    Button(action: {
                        SoundManager.shared.playTransitionSound()
                        self.navegarMenuModoCompeticion = true 
                    }) {
                        Text("VOLVER")
                            .font(.custom("MarkerFelt-Thin", size: 16))
                            .foregroundColor(.black)
                            .padding()
                            .frame(width: 300, height: 75)
                            .background(Color.pastelSilver) 
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 3)
                            )
                    }
                    .fullScreenCover(isPresented: $navegarMenuModoCompeticion) {
                        MenuModoCompeticion(userId: "DummyuserId", userData: UserData(), viewModel: MenuModoCompeticionViewModel())
                    }

                }
            }
            .environment(\.colorScheme, .light)
        }
        .alert(isPresented: $viewModel.muestraAlerta) {
            switch viewModel.alert {
            case .success(let message):
                return Alert(title: Text("Éxito"), message: Text(message), dismissButton: .default(Text("OK"), action: {
                    if viewModel.estaAutenticado {
                        SoundManager.shared.playTransitionSound()
                        navegarMenuModoCompeticion = true
                    }
                }))
            case .mistake(let message):
                return Alert(title: Text("Error"), message: Text(message), dismissButton: .default(Text("OK")))
            case .none:
                return Alert(title: Text("Desconocido"))
            }
        }
        .onChange(of: viewModel.muestraAlerta) { newValue in
            if !newValue && viewModel.estaAutenticado {
                navegarMenuModoCompeticion = true
            }
        }
    }
}

struct GestionarSesion_Previews: PreviewProvider {
    static var previews: some View {
        GestionarSesion()
    }
}
