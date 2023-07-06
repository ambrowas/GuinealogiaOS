import SwiftUI
import AVFAudio

struct MenuPrincipal: View {
    @State private var showMenuModoLibre = false
    @State private var showMenuModoCompeticion = false
    @State private var playerName: String = ""
    @Binding var player: AVAudioPlayer?
    @State private var showContactanosView = false
    private var playerBinding: Binding<AVAudioPlayer?> {
        Binding<AVAudioPlayer?>(
            get: { self.player },
            set: { self.player = $0 }
        )
    }

    var body: some View {
        ZStack {
            Image("coolbackground")
                .resizable()
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 10) {
                Image("logotrivial")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 250)

                Spacer()

                Button(action: {
                    showMenuModoLibre = true
                }) {
                    Text("MODO LIBRE")
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

                Button(action: {
                    showMenuModoCompeticion = true
                }) {
                    Text("MODO COMPETICION")
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
                .sheet(isPresented: $showMenuModoCompeticion) {
                    MenuModoCompeticion(userId: "hardCodedUserId", userData: UserData(), viewModel: RegistrarUsuarioViewModel())
                }




                Button(action: {
                    showContactanosView = true
                }) {
                    Text("CONTACTANOS")
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
                .sheet(isPresented: $showContactanosView) {
                    ContactanosView(player: .constant(nil))
                }



                Spacer()

                Text("2023.INICIATIVAS ELEBI")
                    .foregroundColor(.black)
                    .font(.subheadline)
                    .fontWeight(.bold)

                Text("TODOS LOS DERECHOS RESERVADOS")
                    .foregroundColor(.black)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .padding(.top, -10.0)
            }
            .padding()
        }
        .sheet(isPresented: $showMenuModoLibre) {
            MenuModoLibre()
        }


    }

    struct MenuPrincipal_Previews: PreviewProvider {
        static var previews: some View {
            MenuPrincipal(player: .constant(nil))
        }
    }
}

    
