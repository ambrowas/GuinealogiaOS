import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDatabase

struct MenuModoCompeticion: View {
    @State private var userFullName = ""
    @State private var highestScore = 0
    @State private var showAlertJugar = false
    @State private var showAlertClasificacion = false
    @State private var showAlertPerfil = false
    @State private var jugarModoCompeticionActive = false
    @State private var currentGameFallos = 0
    @State private var showCheckCodigo = false
    @State private var showClasificacion = false
    @State private var showProfile = false
    @State private var showIniciarSesion = false
    @State private var colorIndex: Int = 0
    var userId: String

    @ObservedObject var userData: UserData
    @ObservedObject var viewModel: NuevoUsuarioViewModel
    @State private var alertMessage = ""
    @State private var showAlert = false
    @Environment(\.presentationMode) var presentationMode
    @State private var shouldPresentGameOver: Bool = false
    @State private var shouldPresentResultado: Bool = false
    @State private var goToMenuPrincipal = false
    @State private var shouldNavigateToProfile: Bool = false
    


    private func fetchCurrentUserData() {
        print("Fetching current user data...")
        if let user = Auth.auth().currentUser {
            print("User found: \(user.uid)")
            let ref = Database.database().reference().child("user").child(user.uid)
            
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if let dict = snapshot.value as? [String: Any],
                   
                   let fullname = dict["fullname"] as? String,
                   let highestScore = dict["highestScore"] as? Int {
                    let currentGameFallos = dict["currentGameFallos"] as? Int ?? 0
                    
                    DispatchQueue.main.async {
                        self.userFullName = fullname
                        self.highestScore = highestScore
                        self.currentGameFallos = currentGameFallos
                        
                        // Print fetched values
                        print("Fetched User Fullname: \(self.userFullName)")
                        print("Fetched Highest Score: \(self.highestScore)")
                        print("Fetched Current Game Fallos: \(self.currentGameFallos)")
                    }
                } else {
                    // Print an error message if snapshot could not be cast to [String: Any]
                    print("Error: Snapshot could not be cast to [String: Any]")
                }
            }) { error in
                // Print an error if Firebase could not fetch the data
                print("Error fetching user data from Firebase: \(error.localizedDescription)")
            }
        } else {
            // No user is logged in
            self.userFullName = ""
            self.highestScore = 0
            self.currentGameFallos = 0
            
            // Print a message saying no user is logged in
            print("No user is logged in")
        }
    }

    private func validateCurrentGameFallos() -> Bool {
        return currentGameFallos >= 5
    }
    
    var body: some View {
        NavigationView{
            ZStack {
                Image("coolbackground")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 15) {
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
                    
                    if validateCurrentGameFallos() {
                        
                        Button(action: {
                            showCheckCodigo = true
                        }) {
                            Text("VALIDAR CODIGO")
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
                        .sheet(isPresented: $showCheckCodigo) {
                            CheckCodigo()
                        }
                    } else {
                        Button(action: {
                            if Auth.auth().currentUser != nil {
                                print("User is authenticated. Setting jugarModoCompeticionActive to true.")
                                jugarModoCompeticionActive = true
                            } else {
                                print("No authenticated user found. Showing alert.")
                                alertMessage = "Debes iniciar sesión para poder jugar."
                                showAlert = true
                            }
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
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                        }
                        .fullScreenCover(isPresented: $jugarModoCompeticionActive) {
                            // Your destination view here, for example:
                            JugarModoCompeticion(userId: userId, userData: userData)
                        }
                    }

                    Button(action: {
                        if Auth.auth().currentUser != nil {
                            print("Authenticated user found. Setting showClasificacion to true.")
                            showClasificacion = true
                        } else {
                            print("No authenticated user found. Showing alert for Clasificacion.")
                            alertMessage = "Debes iniciar sesión para poder acceder a la clasificación."
                            showAlert = true
                        }
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
                    .fullScreenCover(isPresented: $showClasificacion) {
                        if let currentUser = Auth.auth().currentUser {
                            ClasificacionView(userId: currentUser.uid)
                        } else {
                            Text("Cargando...")
                        }
                    }
                    
                    Button(action: {
                        if Auth.auth().currentUser != nil {
                            showProfile = true
                        } else {
                            alertMessage = "Debes iniciar sesión para poder acceder a tu perfil."
                            showAlert = true
                        }
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
                    .fullScreenCover(isPresented: $showProfile) {
                        Profile(
                            shouldNavigateToProfile: .constant(true),
                            leaderboardPosition: 1,
                            dismissAction: {
                                showProfile = false
                            }
                        )
                    }

                    Button(action: {
                        if userFullName.isEmpty {
                            print("User full name is empty. Showing Iniciar Sesion.")
                            showIniciarSesion = true
                        } else {
                            print("Trying to logout user...")
                            do {
                                try Auth.auth().signOut()
                                userFullName = ""
                                highestScore = 0
                                currentGameFallos = 0
                            } catch let signOutError as NSError {
                                print("Error signing out: %@", signOutError)
                            }
                        }
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
                    .fullScreenCover(isPresented: $showIniciarSesion) {
                        IniciarSesion(loggedInUserName: $userFullName, showIniciarSesion: $showIniciarSesion)
                            .onDisappear{
                                fetchCurrentUserData()
                            }
                    }
                    NavigationLink("", destination: MenuPrincipal(player: .constant(nil)), isActive: $goToMenuPrincipal).hidden()

                        Button {
                            goToMenuPrincipal = true
                        } label: {
                            Text("VOLVER")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding()
                                .frame(width: 300, height: 55)
                                .cornerRadius(10)
                                
                        }
                    }
                .alert(isPresented: $showAlert) {
                    () -> Alert in
                    print("Showing alert with message: \(alertMessage)")
                    return Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                   }
                .onAppear {
                    print("MenuModoCompeticion view appeared.")
                    fetchCurrentUserData()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
     func getFlashingColor() -> Color {
        let colors: [Color] = [.red, .blue, .green, .white]
        return colors[colorIndex]
    }

     func startFlashing() {
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
struct MenuModoCompeticionNavigation: Identifiable {
    let id = UUID()
}


struct MenuModoCompeticion_Previews: PreviewProvider {
    static var previews: some View {
            MenuModoCompeticion(userId: "DummyuserId", userData: UserData(), viewModel: NuevoUsuarioViewModel()
                )
    }
}


