import SwiftUI
import AVFAudio
import AVFoundation

import SwiftUI
import AVFoundation

struct MenuPrincipal: View {
    @State private var showMenuModoLibre = false
    @State private var showMenuModoCompeticion = false
    @State private var showContactanosView = false
    @State private var showingUpdateAlert = false
    @State private var updateAlertMessage = ""
    @State private var glowColor = Color.blue
    @Binding var player: AVAudioPlayer?
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
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
                    .padding(.top, 20)
                    .shadow(color: glowColor.opacity(0.8), radius: 10, x: 0.0, y: 0.0)
                
                Spacer()
                
                // Buttons for different menu options
                Button("MODO LIBRE") {
                    showMenuModoLibre = true
                    SoundManager.shared.playTransitionSound()
                    
                }
                .buttonStyle(MenuButtonStyle())
                .background(Color(hue: 0.315, saturation: 0.953, brightness: 0.335))
                
                Button("MODO COMPETICION") {
                    showMenuModoCompeticion = true
                    SoundManager.shared.playTransitionSound()
                }
                .buttonStyle(MenuButtonStyle())
                .background(Color(hue: 0.69, saturation: 0.89, brightness: 0.706))
                
                Button("CONTACTANOS") {
                    showContactanosView = true
                    SoundManager.shared.playTransitionSound()
                }
                .buttonStyle(MenuButtonStyle())
                .background(Color(hue: 1.0, saturation: 0.984, brightness: 0.699))
                
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
        .onAppear {
            checkAppVersionAndUpdate()
        }
        .onReceive(timer) { _ in
            glowColor = glowColor == .blue ? .green : .blue
        }
        .fullScreenCover(isPresented: $showMenuModoLibre) {
            MenuModoLibre()
        }
        .fullScreenCover(isPresented: $showMenuModoCompeticion) {
            MenuModoCompeticion(userId: "DummyuserId", userData: UserData(), viewModel: MenuModoCompeticionViewModel())
        }
        .fullScreenCover(isPresented: $showContactanosView) {
            ContactanosView(player: .constant(nil))
        }
        .alert(isPresented: $showingUpdateAlert) {
            Alert(
                title: Text("Actualización Disponible"),
                message: Text(updateAlertMessage),
                dismissButton: .default(Text("Actualizar"), action: {
                    if let url = URL(string: "itms-apps://itunes.apple.com/app/6468170941"),
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                })
            )
        }
    }
    
    func checkAppVersionAndUpdate() {
        let appID = "6468170941" // Replace with your actual App ID
        guard let url = URL(string: "https://itunes.apple.com/lookup?id=\(appID)") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching app data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let appStoreInfo = results.first,
                   let latestVersion = appStoreInfo["version"] as? String,
                   let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                   currentVersion.compare(latestVersion, options: .numeric) == .orderedAscending {
                    
                    DispatchQueue.main.async {
                        self.updateAlertMessage = "Actualización Disponible. Por favor instalate la última versión."
                        self.showingUpdateAlert = true
                    }
                }
            } catch {
                print("Error parsing JSON from App Store: \(error)")
            }
        }.resume()
    }

    
    struct MenuButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(width: 300, height: 75)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 3)
                )
                .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
        }
    }
    
    struct MenuPrincipal_Previews: PreviewProvider {
        static var previews: some View {
            MenuPrincipal(player: .constant(nil))
        }
    }
    
}
