import SwiftUI
import FirebaseAuth

struct ResultadoCompeticion: View {
 @StateObject var userViewModel = UserViewModel()
 @State private var currentUserID = ""
 let userId: String
    
    struct TextRowView: View {
        var title: String
        var value: String
        
        var body: some View {
            HStack {
                Text(title)
                    .font(.title3)
                    .foregroundColor(Color.black)
                    .frame(maxHeight: .infinity)
                    .padding(.vertical, 6)
                Spacer()
                Text(value)
                    .font(.headline)
                    .foregroundColor(Color(hue: 0.994, saturation: 0.963, brightness: 0.695))
                    .frame(maxHeight: .infinity)
                    .padding(.vertical, 6)
            }
        }
    }
    
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
                        .padding(.trailing, 10.0)
                        .frame(width: 100, height: 150)
                    
                    Text("Resultados de \(userViewModel.fullname)")
                        .foregroundColor(.black)
                        .font(.subheadline)
                        .fontWeight(.bold)
                    
                    List {
                        TextRowView(title: "ACIERTOS", value: "\(userViewModel.currentGameAciertos)")
                        TextRowView(title: "ERRORES", value: "\(userViewModel.currentGameFallos)")
                        TextRowView(title: "PUNTOS", value: "\(userViewModel.currentGamePuntuacion)")
                        TextRowView(title: "GANANCIAS", value: "\(userViewModel.currentGamePuntuacion) Fcfas")
                        TextRowView(title: "RANKING GLOBAL", value: "\(userViewModel.positionInLeaderboard)")
                        TextRowView(title: "RECORD", value: "\(userViewModel.highestScore)")
                        TextRowView(title: "TOTAL GANANCIAS", value: "\(userViewModel.highestScore)")
                    }
                    .listStyle(PlainListStyle())
                    .frame(width: 300, height: 310)
                    .background(Color.white)
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black, lineWidth: 3)
                    )
                    
                    VStack(spacing: 10) {
                        NavigationLink(destination: CodigoQR()) {
                            Text("GENERAR COBRO")
                                .font(.headline)
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
                        
                        if let currentUser = Auth.auth().currentUser {
                                              NavigationLink(destination: ClasificacionView(userId: currentUser.uid)) {
                                                  Text("RANKING")
                                                      .font(.headline)
                                                      .foregroundColor(.white)
                                                      .padding()
                                                      .frame(width: 300, height: 55)
                                                      .background(Color(hue: 0.69, saturation: 0.89, brightness: 0.706))
                                                      .cornerRadius(10)
                                                      .overlay(
                                                          RoundedRectangle(cornerRadius: 10)
                                                              .stroke(Color.black, lineWidth: 3)
                                                      )
                                              }
                                          }


                        
                        NavigationLink(destination: MenuModoCompeticion(userId: Auth.auth().currentUser?.uid ?? "defaultId", userData: UserData(), viewModel: RegistrarUsuarioViewModel())) {
                            Text("MENU PRINCIPAL")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 300, height: 55)
                                .background(Color(hue: 0.315, saturation: 0.953, brightness: 0.335))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 3)
                                )
                        }
                    }
                    .onAppear {
                        if let userId = Auth.auth().currentUser?.uid {
                            self.userViewModel.fetchUserData(userId: userId)
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct ResultadoCompeticion_Previews: PreviewProvider {
    static var previews: some View {
        ResultadoCompeticion(userId: Auth.auth().currentUser?.uid ?? "")

    }
}

