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
            Image("tresy")
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
                .font(.custom("MarkerFelt-Thin", size: 16))
                .foregroundColor(.black)
                .frame(width: 280, height: 75)
                .background(Color.pastelSilver)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 3)
                )
                
                Button("MODO COMPETICION") {
                    showMenuModoCompeticion = true
                    SoundManager.shared.playTransitionSound()
                }
                .font(.custom("MarkerFelt-Thin", size: 16))
                .foregroundColor(.black)
                .frame(width: 280, height: 75)
                .background(Color.pastelSilver)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 3)
                )
                
                Button("CONTACTANOS") {
                    showContactanosView = true
                    SoundManager.shared.playTransitionSound()
                }
                .font(.custom("MarkerFelt-Thin", size: 16))
                .foregroundColor(.black)
                .frame(width: 280, height: 75)
                .background(Color.pastelSilver)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 3)
                )
                Spacer()
                
                Text("2023.INICIATIVAS ELEBI")
                    .foregroundColor(.black)
                    .font(.custom("MarkerFelt-Thin", size: 16))
                
                
                Text("TODOS LOS DERECHOS RESERVADOS")
                    .foregroundColor(.black)
                    .font(.custom("MarkerFelt-Thin", size: 16))
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
                title: Text("Actualización Obligatoria"),
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
            print("Invalid URL for App Store version check.")
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
                   let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {

                    if currentVersion.compare(latestVersion, options: .numeric) == .orderedAscending {
                        DispatchQueue.main.async {
                            self.updateAlertMessage = "Nueva versión disponible. Debes actualizar para continuar usando la aplicación."
                            self.showingUpdateAlert = true
                        }
                    } else {
                        print("No update needed: current version \(currentVersion) vs latest \(latestVersion)")
                    }
                }
            } catch {
                print("Error parsing JSON from App Store: \(error)")
            }
        }.resume()
    }

    
    struct MenuPrincipal_Previews: PreviewProvider {
        static var previews: some View {
            MenuPrincipal(player: .constant(nil))
        }
    }
    
}
