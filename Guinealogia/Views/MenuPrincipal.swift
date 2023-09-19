import SwiftUI
import AVFAudio

struct MenuPrincipal: View {
    @State private var showMenuModoLibre = false
    @State private var showMenuModoCompeticion = false
    @State private var playerName: String = ""
    @Binding var player: AVAudioPlayer?
    @State private var showContactanosView = false
    @State private var scale: CGFloat = 1.0
       @State private var glowColor = Color.blue
       let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var playerBinding: Binding<AVAudioPlayer?> {
        Binding<AVAudioPlayer?>(
            get: { self.player },
            set: { self.player = $0 }
        )
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
                       .frame(width: 200, height: 150)
                       .padding(.top, 20)
                       .shadow(color: glowColor.opacity(0.8), radius: 10, x: 0.0, y: 0.0)
                   //    .scaleEffect(scale)
                     //  .animation(
//                        Animation.easeInOut(duration: 1.3)
//                               .repeatForever(autoreverses: true)
//                       )
                       .onAppear {
                           scale = 1.3
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
                    
                    Spacer()
                    
                    NavigationLink(destination: MenuModoLibre()){
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
                    
                    NavigationLink(destination: MenuModoCompeticion(userId: "DummyuserId", userData: UserData(), viewModel: MenuModoCompeticionViewModel())) {
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
                    
                    NavigationLink(destination: ContactanosView(player: .constant(nil))) {
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
        }
        .navigationBarHidden(true)
    }

    struct MenuPrincipal_Previews: PreviewProvider {
        static var previews: some View {
            MenuPrincipal(player: .constant(nil))
        }
    }
}

    
