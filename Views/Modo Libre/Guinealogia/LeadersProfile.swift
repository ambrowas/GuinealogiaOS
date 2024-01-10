import SwiftUI
import FirebaseDatabase
import FirebaseStorage

struct LeadersProfile: View {
    @ObservedObject private var viewModel: LeadersProfileViewModel
    @State private var shouldShowMenuModoCompeticion = false
    
    
    init(userId: String) {
        self.viewModel = LeadersProfileViewModel(userId: userId)
    }
    
    var body: some View {
        ZStack {
            Image("coolbackground")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                // Profile Picture and Circle
                VStack(spacing: 10) {
                    if let profileImageData = viewModel.profileImageData {
                        Image(uiImage: UIImage(data: profileImageData)!)
                            .resizable()
                    
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 150)
                            .border(Color.black, width: 3)
                            .background(Color.white)
                            .padding(.top, 80)
                            .padding(.bottom, 20)
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.top)
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
                    
                    Circle()
                        .stroke(Color.black, lineWidth: 2) // black border
                        .background(Circle().fill(Color(hue: 1.0, saturation: 0.984, brightness: 0.699))) // red circle
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
                
                ScrollView {
                    VStack(spacing: 10) {
                        if let user = viewModel.user {
                            TextRowView(title: "NOMBRE", value: user.fullname)
                            TextRowView(title: "BARRIO", value: user.barrio)
                            TextRowView(title: "CIUDAD", value: user.ciudad)
                            TextRowView(title: "PAIS", value: user.pais)
                        
                            TextRowView(title: "PUNTUACIÓN ACUMULADA", value: "\(user.accumulatedPuntuacion)")
                            TextRowView(title: "ACIERTOS ACUMULADOS", value: "\(user.accumulatedAciertos)")
                            TextRowView(title: "FALLOS ACUMULADOS", value: "\(user.accumulatedFallos)")
                            TextRowView(title: "RECORD", value: "\(user.highestScore)")
                            TextRowView(title: "PASTA ACUMULADA", value: "\(user.accumulatedPuntuacion ) FCFA")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 50)
                    
                    
                }
                .padding(.top, 10)
                
                // Volver Button
                Button(action: {
                    shouldShowMenuModoCompeticion = true
                }) {
                    Text("VOLVER")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 55)
                        .background(Color(hue: 1.0, saturation: 0.984, brightness: 0.699))
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
            .sheet(isPresented: $shouldShowMenuModoCompeticion) {
                MenuModoCompeticion(userId: "hardCodedUserId", userData:UserData(), viewModel: RegistrarUsuarioViewModel())
            }
        }
    }
    
    
    
    struct LeadersProfile_Previews: PreviewProvider {
        static var previews: some View {
            LeadersProfile(userId: "PoGQOuIby2Y1mVf2bhYSidOLU7v1")
            
        }
    }
    
    final class LeadersProfileViewModel: ObservableObject {
        @Published var user: ProfileUser?
        private let userId: String
        @Published var profileImageData: Data?
        
        init(userId: String) {
            self.userId = userId
        }
        
        func fetchUserDataFromRealtimeDatabase() {
            let ref = Database.database().reference().child("user").child(userId)
            ref.observeSingleEvent(of: .value) { snapshot in
                if let value = snapshot.value as? [String: Any] {
                    let fullname = value["fullname"] as? String ?? "Unknown"
                    let barrio = value["barrio"] as? String ?? "Unknown"
                    let ciudad = value["ciudad"] as? String ?? "Unknown"
                    let pais = value["pais"] as? String ?? "Unknown"
                    let positionInLeaderboard = value["positionInLeaderboard"] as? Int ?? 0
                    let accumulatedPuntuacion = value["accumulatedPuntuacion"] as? Int ?? 0
                    let accumulatedAciertos = value["accumulatedAciertos"] as? Int ?? 0
                    let accumulatedFallos = value["accumulatedFallos"] as? Int ?? 0
                    let highestScore = value["highestScore"] as? Int ?? 0
                    let profilePicture = value["profilePicture"] as? String ?? ""
                    
                    DispatchQueue.main.async {
                        self.user = ProfileUser(
                            id: self.userId,
                            fullname: fullname,
                            barrio: barrio,
                            ciudad: ciudad,
                            pais: pais,
                            positionInLeaderboard: positionInLeaderboard,
                            accumulatedPuntuacion: accumulatedPuntuacion,
                            accumulatedAciertos: accumulatedAciertos,
                            accumulatedFallos: accumulatedFallos,
                            highestScore: highestScore,
                            profilePictureURL: profilePicture
                        )
                        self.fetchProfileImage(urlString: self.user?.profilePictureURL)
                    }
                }
            }
        }
        
        
        func fetchProfileImage(urlString: String?) {
            guard let urlString = urlString,
                  let url = URL(string: urlString),
                  UIApplication.shared.canOpenURL(url) else {
                print("Invalid URL")
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil else {
                    print("Failed to fetch image:", error ?? "No error information")
                    return
                }
                
                DispatchQueue.main.async {
                    self.profileImageData = data
                }
            }.resume()
        }
    }
    
    struct TextRowView: View {
        var title: String
        var value: String
        
        var body: some View {
            HStack {
                Text(title)
                    .bold()
                    .foregroundColor(Color.gray)
                Spacer()
                Text(value)
                    .foregroundColor(Color.blue)
                    .bold()
            }
          
            
        }
        
    }
    
    struct ProfileUser: Equatable {
        let id: String
        let fullname: String
        let barrio: String
        let ciudad: String
        let pais: String
        let positionInLeaderboard: Int
        let accumulatedPuntuacion: Int
        let accumulatedAciertos: Int
        let accumulatedFallos: Int
        let highestScore: Int
        var profilePictureURL: String
        
        static func ==(lhs: ProfileUser, rhs: ProfileUser) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
}
