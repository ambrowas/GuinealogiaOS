import SwiftUI
import FirebaseAuth



struct ResultadoCompeticion: View {
    @StateObject var userViewModel = UserViewModel()
    @State private var isButtonDisabled = false
    @State private var activeAlert: ActiveAlert? = nil
    @State private var showCodigo = false
    let userId: String
    @Environment(\.presentationMode) var presentationMode
    @State private var goToMenuModoCompeticion: Bool = false
    @State private var goToMenuPrincipal: Bool = false
    @State private var goToClasificacion: Bool = false
    @State private var isButtonCoolingDown = false

    enum ActiveAlert: Identifiable {
        case minimoCobro, esperaNecesaria, confirmarSalida

        var id: String {
            switch self {
            case .minimoCobro:
                return "minimoCobro"
            case .esperaNecesaria:
                return "esperaNecesaria"
            case .confirmarSalida:
                return "confirmarSalida"
            }
        }
    }
    
    private func initiateCooldown() {
        // Indicate the button is in its cooldown period.
        isButtonCoolingDown = true

        // Schedule the end of the cooldown period.
        DispatchQueue.main.asyncAfter(deadline: .now() + 180) {
            self.isButtonCoolingDown = false
        }
    }


    var body: some View {
        ZStack {
            // Background Image
            Image("tresy")
                .resizable()
                .edgesIgnoringSafeArea(.all)

            // Main Content
            VStack(spacing: 10) {
                // Trivial Logo
                Image("logotrivial")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.top, -50)
                    .frame(width: 100, height: 150)

                // Title
                Text("Resultados de \(userViewModel.fullname)")
                    .foregroundColor(.black)
                    .font(.custom("MarkerFelt-Thin", size: 18))
                    .fontWeight(.bold)
                    .padding(.top, -20)

                // Data List
                List {
                    TextRowView(title: "ACIERTOS", value: "\(userViewModel.currentGameAciertos)")
                    TextRowView(title: "ERRORES", value: "\(userViewModel.currentGameFallos)")
                    TextRowView(title: "PUNTOS", value: "\(userViewModel.currentGamePuntuacion)")
                    TextRowView(title: "GANANCIAS", value: "\(userViewModel.currentGamePuntuacion) FCFA")
                    TextRowView(title: "RANKING GLOBAL", value: "\(userViewModel.positionInLeaderboard)")
                    TextRowView(title: "RECORD", value: "\(userViewModel.highestScore)")
          TextRowView(title: "GANANCIA TOTAL", value: "\(userViewModel.accumulatedPuntuacion) FCFA")
                }
                .listStyle(PlainListStyle())
                .frame(width: 300, height: 310)
                .background(Color.pastelSilver)
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.black, lineWidth: 3)
                )
                .environment(\.colorScheme, .light)

                // Buttons
                VStack(spacing: 10) {
                    Button(action: {
                        // Check if the button is actively cooling down.
                        if isButtonCoolingDown {
                            SoundManager.shared.playError()
                            activeAlert = .esperaNecesaria
                        } else {
                            // If it's not cooling down, proceed with the GENERAR COBRO action.
                            SoundManager.shared.playTransitionSound()

                            // Check the user's points.
                            if userViewModel.currentGamePuntuacion >= 2500 {
                                SoundManager.shared.playTransitionSound()
                                showCodigo = true
                            } else {
                                SoundManager.shared.playError()
                                activeAlert = .minimoCobro
                            }
                            
                            // Initiate the cooldown period.
                            initiateCooldown()
                        }
                    }) {
                        Text("GENERAR COBRO")
                            .font(.custom("MarkerFelt-Thin", size: 18))
                            .foregroundColor(.black)
                            .padding()
                            .frame(width: 300, height: 55)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 3)
                            )
                    }
                    .disabled(isButtonDisabled)
                    .fullScreenCover(isPresented: $showCodigo) {
                        
                        // Present the full-screen cover view to display the QR code or cobro details
                        // Make sure to define this view or replace with the correct view you have for QR/cobro
                        CodigoQR()
                    }

                    // CLASIFICACION Button
                    Button(action: {
                        if Auth.auth().currentUser != nil {
                            SoundManager.shared.playTransitionSound()
                            goToClasificacion = true
                        } else {
                            // Handle unauthenticated user case
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
                    .fullScreenCover(isPresented: $goToClasificacion) {
                    ClasificacionView(userId: Auth.auth().currentUser?.uid ?? "")
                                            }
                    // MENU PRINCIPAL Button
                    Button(action: {
                        SoundManager.shared.playNo()
                            activeAlert = .confirmarSalida
                 
                    }) {
                        Text("MENU PRINCIPAL")
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
                    .fullScreenCover(isPresented: $goToMenuPrincipal) {
                  MenuPrincipal(player: .constant(nil))
                                           }

                }

                // Alerts
                .alert(item: $activeAlert) { alertType in
                    switch alertType {
                    case .minimoCobro:
                        SoundManager.shared.playError()
                        return Alert(
                            title: Text(""),
                            message: Text("Debes generar un mínimo de 2500 FCFA"),
                            dismissButton: .default(Text("OK")) {
                                SoundManager.shared.playTransitionSound()
                            }
                        )
                        
                    case .esperaNecesaria:
                        SoundManager.shared.playError()
                        return Alert(
                            title: Text(""),
                            message: Text("Ya generaste este código."),
                            dismissButton: .default(Text("OK")) {
                                SoundManager.shared.playTransitionSound()
                            }
                        )
                
                    case .confirmarSalida:
                        SoundManager.shared.playNo()
                        return Alert(
                            title: Text("Confirmar"),
                            message: Text("¿Seguro que quieres salir?"),
                            primaryButton: .default(Text("Si")) {
                                SoundManager.shared.playTransitionSound()
                                goToMenuPrincipal = true
                            },
                            secondaryButton: .cancel(Text("Cancelar")) {
                                SoundManager.shared.playTransitionSound()
                            }
                        )}
                        
                    }
                }
            }
            .onAppear {
                userViewModel.fetchUserData { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(): break
                            // If necessary, perform any actions following a successful data fetch.
                        case .failure(let error):
                            // Handle and/or display the error to the user.
                            print("Error while fetching user data: \(error.localizedDescription)")
                        }
                    }
                }
                }
            }
        }
    

    // Helper View for Text Rows
struct TextRowView: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.custom("MarkerFelt-Thin", size: 18))
                .foregroundColor(Color.black)
                .frame(maxWidth: .infinity, alignment: .leading) // Align text to the leading edge
                .lineLimit(1) // Ensure title is in a single line
                .padding(.vertical, 4) // Adjust padding for smaller content

            Spacer() // Use a spacer to push content to opposite ends

            Text(value)
                .font(.custom("MarkerFelt-Thin", size: 18))
                .foregroundColor(Color.deepBlue)
                .frame(maxWidth: .infinity, alignment: .trailing) // Align text to the trailing edge
                .padding(.vertical, 4) // Adjust padding for smaller content
        }
    }
}






struct ResultadoCompeticion_Previews: PreviewProvider {
    static var previews: some View {
        ResultadoCompeticion(userId: "exampleUserId")
    }
}
