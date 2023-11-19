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
    

    var body: some View {
        ZStack {
            Image("coolbackground")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 15) {
                Text(viewModel.userFullName)
                    .foregroundColor(.black)
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                
                if !viewModel.userFullName.isEmpty {
                    Text("Tu record es de \(viewModel.highestScore) puntos")
                        .foregroundColor(viewModel.getFlashingColor())
                        .font(.headline)
                        .padding(.horizontal, 20)
                        .padding(.top, -10)
                }
                
                    if viewModel.validateCurrentGameFallos() {
                        
                        Button(action: {
                            SoundManager.shared.playTransitionSound()
                                   showCheckCodigo = true
                               }) {
                                   Text("VALIDAR CODIGO")
                                       .font(.headline)
                                       .foregroundColor(.black)
                                       .padding()
                                       .frame(width: 300, height: 75)
                                       .background(isFlashing ? Color.white : Color.red)
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
                        // Start a timer to toggle the flashing effect repeatedly
                            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                            withAnimation {
                            isFlashing.toggle()
                              }
                                }
                        }
                        
                   
                } else {
                    Button(action: {
                        if Auth.auth().currentUser != nil {
                            SoundManager.shared.playTransitionSound()
                            jugarModoCompeticionActive = true
                        } else {
                            alertMessage = "Debes iniciar sesión para poder jugar."
                            showAlert = true
                        }
                    }) {
                        Text("JUGAR")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 300, height: 75)
                            .background(isFlashing ? Color.white : Color(hue: 1.0, saturation: 0.984, brightness: 0.699))
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
                        SoundManager.shared.playTransitionSound()
                        showClasificacion = true
                    } else {
                        alertMessage = "Debes iniciar sesión para poder acceder a la clasificación."
                        showAlert = true
                    }
                }) {
                    Text("CLASIFICACION")
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
                .fullScreenCover(isPresented: $showClasificacion) {
                    if let currentUser = Auth.auth().currentUser {
                        ClasificacionView(userId: currentUser.uid)
                    } else {
                        Text("Cargando...")
                    }
                }
                
                Button(action: {
                    if Auth.auth().currentUser != nil {
                        SoundManager.shared.playTransitionSound()
                        showProfile = true
                    } else {
                        alertMessage = "Debes iniciar sesión para poder acceder a tu perfil."
                        showAlert = true
                    }
                }) {
                    Text("PERFIL")
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
                .fullScreenCover(isPresented: $showProfile) {
                    Profile ()
                }
                
                Button(action: {
                    if viewModel.userFullName.isEmpty {
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
                    Text(viewModel.userFullName.isEmpty ? "INICIAR SESION" : "CERRAR SESION")
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
                    GestionarSesion()
                        .onDisappear{
                            viewModel.fetchCurrentUserData()
                        }
                }
                
                Button {
                    SoundManager.shared.playTransitionSound()
                    self.showMenuPrincipalSheet = true
                } label: {
                    Text("VOLVER")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(width: 300, height: 55)
                        .cornerRadius(10)
                    
                }
             
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
    

