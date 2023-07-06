import SwiftUI
import Firebase

struct MenuModoCompeticion: View {
    @State private var userFullName = ""
    @State private var highestScore = 0
    @State private var showAlertJugar = false
    @State private var showAlertClasificacion = false
    @State private var showAlertPerfil = false
    @State private var jugarModoCompeticionActive = false
    @State private var showClasificacion = false
    @State private var showProfile = false
    @State private var showIniciarSesion = false
    @State private var colorIndex: Int = 0
    var userId: String
    @ObservedObject var userData: UserData
    @ObservedObject var viewModel: RegistrarUsuarioViewModel

    private func fetchUserData() {
        if let user = Auth.auth().currentUser {
            // A user is logged in, fetch their data
            let ref = Database.database().reference().child("user").child(user.uid)
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if let dict = snapshot.value as? [String: Any],
                   let fullname = dict["fullname"] as? String,
                   let highestScore = dict["highestScore"] as? Int {
                    DispatchQueue.main.async {
                        self.userFullName = fullname
                        self.highestScore = highestScore
                    }
                }
            })
        } else {
            // No user is logged in
            self.userFullName = ""
            self.highestScore = 0
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Image("coolbackground")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 15) {
                    Image("logotrivial")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.top, 15)
                        .frame(width: 200, height: 150)

                    Text(userFullName.isEmpty ? "Usuario Desconectado" : userFullName)
                        .foregroundColor(.black)
                        .font(.headline)
                        .padding(.horizontal, 20)
                        .padding(.top, 60)

                    if !userFullName.isEmpty {
                        Text("Tu record es de \(highestScore) puntos")
                            .foregroundColor(getFlashingColor())
                            .font(.headline)
                            .padding(.horizontal, 20)
                            .padding(.top, -10)
                    }
                    
                    Button(action: {
                        jugarModoCompeticionActive = true
                    }) {
                        Text("JUGAR")
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
                    .alert(isPresented: $showAlertJugar) {
                        Alert(
                            title: Text("Alert"),
                            message: Text("Debes iniciar sesión para poder jugar."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    .sheet(isPresented: $jugarModoCompeticionActive) {
                        JugarModoCompeticion(userId: userId, userData: userData)
                    }
                    
                    Button(action: {
                        showClasificacion = true
                    }) {
                        Text("CLASIFICACION")
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
                    .alert(isPresented: $showAlertClasificacion) {
                        Alert(
                            title: Text("Alert"),
                            message: Text("Debes iniciar sesión para poder acceder a la clasificación."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    .sheet(isPresented: $showClasificacion) {
                        if let currentUser = Auth.auth().currentUser {
                            ClasificacionView(userId: currentUser.uid)
                        } else {
                            Text("Cargando...")
                        }
                    }
                    
                    
                    Button(action: {
                        showProfile = true
                    }) {
                        Text("PERFIL")
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
                    .alert(isPresented: $showAlertPerfil) {
                        Alert(
                            title: Text("Alert"),
                            message: Text("Debes iniciar sesión para poder acceder a tu perfil."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    .sheet(isPresented: $showProfile) {
                        let userViewModel = UserViewModel() // No arguments here
                        ProfileView(userViewModel: userViewModel, leaderboardPosition: 1, dismissAction: {
                            // Handle dismissal action here
                            showProfile = false
                        })
                    }
                    
                    
                    
                    Button(action: {
                        showIniciarSesion = true
                    }) {
                        Text(userFullName.isEmpty ? "INICIAR SESION" : "CERRAR SESION")
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
                    .sheet(isPresented: $showIniciarSesion) {
                        IniciarSesion(loggedInUserName: $userFullName, showIniciarSesion: $showIniciarSesion)
                    }
                }
                             .onAppear {
                                 fetchUserData()
                             }
                         }
                         .navigationBarHidden(true)
                     }
                 }

                 private func getFlashingColor() -> Color {
                     let colors: [Color] = [.red, .blue, .green, .white]
                     return colors[colorIndex]
                 }

                 private func startFlashing() {
                     let flashingColors: [Color] = [.red, .blue, .green, .white]

                     let flashingAnimation = Animation
                         .linear(duration: 0.5)
                         .repeatForever(autoreverses: true)

                     withAnimation(flashingAnimation) {
                         colorIndex = 0
                     }

                     for (index, _) in flashingColors.enumerated() {
                         DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                             withAnimation(flashingAnimation) {
                                 colorIndex = index
                             }
                         }
                     }
                 }
             }

             struct MenuModoCompeticion_Previews: PreviewProvider {
                 static var previews: some View {
                     MenuModoCompeticion(userId: "DummyuserId", userData: UserData(), viewModel: RegistrarUsuarioViewModel())
                 }
             }
