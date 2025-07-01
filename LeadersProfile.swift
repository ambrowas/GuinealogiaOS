import SwiftUI

import FirebaseStorage

struct LeadersProfile: View {
    @StateObject private var viewModel: LeadersProfileViewModel
    @State private var shouldShowMenuModoCompeticion = false
    @Environment(\.presentationMode) var presentationMode
    @State private var userData: UserData = UserData()
    @State private var showSheet: Bool = false
    @State private var goToMenuCompeticion: Bool = false

    
    init(userId: String) {
           _viewModel = StateObject(wrappedValue: LeadersProfileViewModel(userId: userId))
       }


    
    var body: some View {
        ZStack {
            Image("dosy")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                
                // Profile Picture with Medal (bottom-left)
                ZStack(alignment: .bottomLeading) {
                    if let profileImageData = viewModel.profileImageData,
                       let uiImage = UIImage(data: profileImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 150)
                            .border(Color.black, width: 3)
                            .background(Color.pastelSilver)
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 150)
                            .border(Color.black, width: 3)
                            .foregroundColor(.gray)
                            .overlay(
                                VStack {
                                    Text("Foto de Perfil")
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                }
                            )
                    }

                    if let position = viewModel.user?.positionInLeaderboard,
                       let (medalImage, medalType) = medalImage(for: position) {
                        medalImage
                            .resizable()
                            .frame(width: 40, height: 40)
                            .glowingMedalEffect(for: medalType)
                            .offset(x: -10, y: 10)
                    }
                }
                .padding(.top, 80)
                .padding(.bottom, 20)
                
                // Circle (bottom-right position indicator)
                if #available(iOS 16.0, *) {
                    Circle()
                        .stroke(Color.black, lineWidth: 2)
                        .background(Circle().fill(Color(hue: 1.0, saturation: 0.984, brightness: 0.699)))
                        .frame(width: 100, height: 100)
                        .padding(.leading, 200)
                        .padding(.top, -70)
                        .overlay(
                            FlashingText(text: "\(viewModel.user?.positionInLeaderboard ?? 0)", shouldFlash: true)
                                .foregroundColor(.white)
                                .font(.largeTitle)
                                .bold()
                                .padding(.leading, 200)
                                .padding(.top, -50)
                        )
                }
                
                // Scrollable User Info
                ScrollView {
                    VStack(spacing: 0) {
                        if let user = viewModel.user {
                            Group {
                                TextRowView(title: "NOMBRE", value: user.fullname)
                                Divider().background(Color.black)
                                TextRowView(title: "BARRIO", value: user.barrio)
                                Divider().background(Color.black)
                                TextRowView(title: "CIUDAD", value: user.ciudad)
                                Divider().background(Color.black)
                                TextRowView(title: "PAIS", value: user.pais)
                                Divider().background(Color.black)
                                TextRowView(title: "PUNTUACIÓN ACUMULADA", value: "\(user.accumulatedPuntuacion)")
                                Divider().background(Color.black)
                                TextRowView(title: "ACIERTOS ACUMULADOS", value: "\(user.accumulatedAciertos)")
                                Divider().background(Color.black)
                                TextRowView(title: "FALLOS ACUMULADOS", value: "\(user.accumulatedFallos)")
                                Divider().background(Color.black)
                                TextRowView(title: "RECORD", value: "\(user.highestScore)")
                                Divider().background(Color.black)
                                TextRowView(title: "PASTA ACUMULADA", value: "\(user.accumulatedPuntuacion) FCFA")
                            }
                        }
                    }
                    .background(Color.pastelSilver)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 2)
                    )
                    .padding(.horizontal, 30)
                    .frame(maxWidth: 350)
                }

                // Volver Button
                Button(action: {
                    SoundManager.shared.playTransitionSound()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("VOLVER")
                        .font(.custom("MarkerFelt-Thin", size: 18))
                        .foregroundColor(.black)
                        .padding()
                        .frame(width: 300, height: 55)
                        .background(Color.pastelSilver)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 3)
                        )
                }
                .padding(.bottom, 60)
            }
            .onAppear {
                self.viewModel.fetchUserDataFromRealtimeDatabase()
            }
        }
    }
    
    func medalImage(for position: Int) -> (Image, MedalType)? {
        switch position {
        case 1:
            return (Image("medallaoro"), .oro)
        case 2:
            return (Image("medallaplata"), .plata)
        case 3:
            return (Image("medallabronce"), .bronce)
        default:
            return nil
        }
    }
    
    struct LeadersProfile_Previews: PreviewProvider {
        static var previews: some View {
            LeadersProfile(userId: "DummyUserId")

            
        }
    }
    
    

    struct TextRowView: View {
        let title: String
        let value: String

        var body: some View {
            HStack {
                Text(title)
                    .font(.custom("MarkerFelt-Thin", size: 14))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(value)
                    .font(.custom("MarkerFelt-Thin", size: 14))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(Color.white)
        }
        
    }
    
   
    
}
