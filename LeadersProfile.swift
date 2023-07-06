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
            VStack(spacing: 10) {
                if let profileImageData = viewModel.profileImageData {
                    Image(uiImage: UIImage(data: profileImageData)!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 150)
                        .border(Color.black, width: 3)
                        .padding(.top, 100)
                        .padding(.bottom, 50)
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
            
                ScrollView {
                    VStack(spacing: 10) {
                        if let user = viewModel.user {
                            TextRowView(title: "NOMBRE", value: user.fullname)
                             
                            TextRowView(title: "BARRIO", value: user.barrio)
                            
                            TextRowView(title: "CIUDAD", value: user.ciudad)
                             
                            TextRowView(title: "PAIS", value: user.pais)
                      
                            TextRowView(title: "PUESTO EN EL RANKING", value: "\(user.positionInLeaderboard)")
                              
                            TextRowView(title: "PUNTUACIÓN ACUMULADA", value: "\(user.accumulatedPuntuacion)")
                           
                            TextRowView(title: "ACIERTOS ACUMULADOS", value: "\(user.accumulatedAciertos)")
                        
                           
                            TextRowView(title: "FALLOS ACUMULADOS", value: "\(user.accumulatedFallos)")
                    
                              
                                
                            TextRowView(title: "PUNTUACIÓN MÁS ALTA", value: "\(user.highestScore)")
                            
                            
                                
                                
                            
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 50)
                    
                    
                }
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
                .padding(.bottom, 80)
               
                
            }
            .onAppear {
                self.viewModel.fetchUserDataFromRealtimeDatabase()
            }
            .sheet(isPresented: $shouldShowMenuModoCompeticion) {
                MenuModoCompeticion(userId: "hardCodedUserId", userData:UserData(), viewModel: RegistrarUsuarioViewModel())
            }
        }
    }
}

struct LeadersProfile_Previews: PreviewProvider {
    static var previews: some View {
        LeadersProfile(userId: "IpCOXNcQNLgCe9fR4UM3hEhGTOf1")

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
            if let value = snapshot.value as? [String: Any],
               let fullname = value["fullname"] as? String,
               let barrio = value["barrio"] as? String,
               let ciudad = value["ciudad"] as? String,
               let pais = value["pais"] as? String,
               let positionInLeaderboard = value["positionInLeaderboard"] as? Int,
               let accumulatedPuntuacion = value["accumulatedPuntuacion"] as? Int,
               let accumulatedAciertos = value["accumulatedAciertos"] as? Int,
               let accumulatedFallos = value["accumulatedFallos"] as? Int,
               let highestScore = value["highestScore"] as? Int,
               let profilePicture = value["profilePicture"] as? String {
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
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            
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
                .foregroundColor(Color.black)
        }
        .padding(.vertical, 5)
        .fixedSize(horizontal: false, vertical: true)
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

