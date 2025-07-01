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
    @ObservedObject var viewModel: MenuModoCompeticionViewModel
    @State private var alertMessage = ""
    @State private var showAlert = false
    @Environment(\.presentationMode) var presentationMode
    @State private var shouldPresentGameOver: Bool = false
    @State private var shouldPresentResultado: Bool = false
    @State private var shouldNavigateToProfile: Bool = false
    @State private var shouldPresentProfile = false
    @State private var showMenuPrincipalSheet = false
    @State private var isFlashing = false
    @State private var timer: Timer?
    
    

    var body: some View {
        ZStack {
            Image("tresy")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 15) {
                if viewModel.isUserLoggedIn {
                    Text("Mbolo, \(viewModel.userFullName)")
                        
                        .foregroundColor(.deepBlue)
                    Text("Tu record es de \(viewModel.highestScore) puntos")
                        .font(.custom("MarkerFelt-Thin", size: 20))
                        .foregroundColor(.darkRed)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                } else {
                    Text("INICIAR SESION / REGISTRAR USUARIO")
                        .font(.custom("MarkerFelt-Thin", size: 18))
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                }
                
                
                if viewModel.isUserLoggedIn && viewModel.validateCurrentGameFallos() {
                    Button(action: {
                        SoundManager.shared.playTransitionSound()
                        showCheckCodigo = true
                    }) {
                        Text("VALIDAR CODIGO")
                            .font(.custom("MarkerFelt-Thin", size: 18))
                            .foregroundColor(.black)
                            .padding()
                            .frame(width: 300, height: 75)
                            .background(isFlashing ? Color.red : Color.pastelSilver)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 3)
                            )
                    }
                    .fullScreenCover(isPresented: $showCheckCodigo) {
                        CheckCodigo()
                    }
                    .onAppear {
                        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                            withAnimation {
                                isFlashing.toggle()
                            }
                        }
                    }
                    .onDisappear {
                        timer?.invalidate()
                        timer = nil
                    }
                
                        
                } else {
                    Button(action: {
                        if viewModel.isUserLoggedIn {
                            SoundManager.shared.playTransitionSound()
                            jugarModoCompeticionActive = true
                        } else {
                            SoundManager.shared.playError()
                            alertMessage = "Debes iniciar sesión para poder jugar."
                            showAlert = true
                        }
                    }) {
                        Text("JUGAR")
                            .font(.custom("MarkerFelt-Thin", size: 18))
                            .foregroundColor(.black)
                            .padding()
                            .frame(width: 300, height: 75)
                            .background(Color.pastelSilver) // Not affected by flashing
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
                    if viewModel.isUserLoggedIn {
                        SoundManager.shared.playTransitionSound()
                        showClasificacion = true
                    } else {
                        SoundManager.shared.playError()
                        alertMessage = "Debes iniciar sesión para poder acceder a la clasificación."
                        showAlert = true
                    }
                }) {
                    Text("CLASIFICACION")
                        .font(.custom("MarkerFelt-Thin", size: 18))
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
                .fullScreenCover(isPresented: $showClasificacion) {
                    if let currentUser = Auth.auth().currentUser {
                        ClasificacionView(userId: currentUser.uid)
                    } else {
                        Text("Cargando...")
                    }
                }
                
                Button(action: {
                    if viewModel.isUserLoggedIn {
                        SoundManager.shared.playTransitionSound()
                        showProfile = true
                    } else {
                        SoundManager.shared.playError()
                        alertMessage = "Debes iniciar sesión para poder acceder a tu perfil."
                        showAlert = true
                    }
                }) {
                    Text("PERFIL")
                        .font(.custom("MarkerFelt-Thin", size: 18))
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
                .fullScreenCover(isPresented: $showProfile) {
                    Profile ()
                }
                
                Button(action: {
                    if viewModel.isUserLoggedIn {
                        SoundManager.shared.playTransitionSound()
                        showIniciarSesion = true
                    } else {
                        do {
                            try Auth.auth().signOut()
                            SoundManager.shared.playTransitionSound()
                            viewModel.userFullName = ""
                            viewModel.highestScore = 0
                            viewModel.currentGameFallos = 0
                        } catch let signOutError as NSError {
                          
                        }
                    }
                }) {
                    Button(action: {
                        SoundManager.shared.playTransitionSound()
                        showIniciarSesion = true
                    }) {
                        Text(viewModel.userFullName.isEmpty ? "INICIAR SESION" : "CERRAR SESION")
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
                    .fullScreenCover(isPresented: $showIniciarSesion) {
                        GestionarSesion()
                            .onDisappear {
                                viewModel.fetchCurrentUserData()
                            }
                    }
                }
                Button {
                    SoundManager.shared.playTransitionSound()
                    self.showMenuPrincipalSheet = true
                } label: {
                    Text("VOLVER")
                        .font(.custom("MarkerFelt-Thin", size: 18))
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
                .padding(.top, 60)
             
                .fullScreenCover(isPresented: $showMenuPrincipalSheet) {
                    MenuPrincipal(player: .constant(nil))
                }
            }
            .alert(isPresented: $showAlert) {
                () -> Alert in
                return Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                viewModel.checkAndStartBatchProcess()
                if viewModel.userFullName.isEmpty {
                    viewModel.fetchCurrentUserData()
                    
               
                    }
                }
            
            
        
        }
        
    }
    
    struct MenuModoCompeticionNavigation: Identifiable {
        let id = UUID()
    }
    
    
    struct MenuModoCompeticion_Previews: PreviewProvider {
        static var previews: some View {
            MenuModoCompeticion(userId: "DummyuserId", userData: UserData(), viewModel: MenuModoCompeticionViewModel()
            )
        }
    }
    
}
    

