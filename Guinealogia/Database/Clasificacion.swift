import SwiftUI
import Firebase
import FirebaseDatabase

    struct User: Identifiable {
        var id: String
        var fullname: String
        var ciudad: String
        var accumulatedPuntuacion: Int
        var leaderboardPosition: Int
        var scoreAchievedAt: Date? // making this optional
    }

    class UserData: ObservableObject {
        @Published var users = [User]()
        
        private var db = Database.database().reference()
        
        init() {
            fetchUsers()
        }
        
        func fetchUsers() {
            db.child("user")
                .queryOrdered(byChild: "accumulatedPuntuacion")
                .queryLimited(toLast: 25)
                .observe(.value) { (snapshot) in
                    print("Number of snapshots fetched: \(snapshot.childrenCount)")
                    var newUsers = [User]()
                    for child in snapshot.children {
                        if let snapshot = child as? DataSnapshot,
                           let user = User(snapshot: snapshot) {
                            newUsers.append(user)
                        } else {
                           print("Failed to parse snapshot: \(child)")
                                        }
                                    }
                                    
                        print("Number of users parsed: \(newUsers.count)")
                    
                    DispatchQueue.main.async {
                        // First, sort the users array by `accumulatedPuntuacion`
                        newUsers.sort { $0.accumulatedPuntuacion > $1.accumulatedPuntuacion }
                        // Then, for users with equal `accumulatedPuntuacion`, sort by `scoreAchievedAt`
                        newUsers = newUsers.sorted {
                            if $0.accumulatedPuntuacion == $1.accumulatedPuntuacion {
                                return $0.scoreAchievedAt ?? Date.distantPast > $1.scoreAchievedAt ?? Date.distantPast
                            }
                            return $0.accumulatedPuntuacion > $1.accumulatedPuntuacion
                        }
                        self.users = newUsers
                        self.updateLeaderboardPositions()
                    }
                }
        }
        
        func updateLeaderboardPositions() {
            var currentLeaderboardPosition = 1
            
            for (index, _) in users.enumerated() {
                users[index].leaderboardPosition = currentLeaderboardPosition
                currentLeaderboardPosition += 1
            }
        }
    }

extension User {
    init?(snapshot: DataSnapshot) {
        guard let value = snapshot.value as? [String: Any],
              let fullname = value["fullname"] as? String,
              let ciudad = value["ciudad"] as? String else {
            print("Failed to parse required fields for snapshot: \(snapshot.key)")
            return nil
        }
        
        self.id = snapshot.key
        self.fullname = fullname
        self.ciudad = ciudad
        self.accumulatedPuntuacion = value["accumulatedPuntuacion"] as? Int ?? 0 // provide default value if missing
        self.leaderboardPosition = 0 // Placeholder value, it will be updated later
        
        if let scoreAchievedAt = value["scoreAchievedAt"] as? Double {
            self.scoreAchievedAt = Date(timeIntervalSince1970: scoreAchievedAt)
        } else {
            self.scoreAchievedAt = nil
        }
    }
}
    
    struct FlashingText: View {
        let text: String
        let shouldFlash: Bool
        @State private var colorIndex: Int = 0
        @State private var timer: Timer? = nil
        
        var body: some View {
            Text(text)
                .foregroundColor(getColor())
                .onAppear {
                    if shouldFlash {
                        startFlashing()
                    }
                }
                .onDisappear {
                    timer?.invalidate()
                    timer = nil
                }
        }
        
        private func getColor() -> Color {
            let colors: [Color] = [.black, .red, .blue, .white, .green]
            return colors[colorIndex % colors.count]
        }
        
        private func startFlashing() {
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                colorIndex = (colorIndex + 1) % 5
            }
        }
    }
    
    struct ClasificacionView: View {
        @Environment(\.presentationMode) var presentationMode
        @StateObject private var userData = UserData()
        @State private var shouldShowMenuModoCompeticion = false
        @State private var selectedUserId: String? = nil
        let userId: String
        
        var body: some View {
            NavigationView {
                ZStack {
                    Image("coolbackground")
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                    
                    
                    VStack(spacing: 10) {
                        Spacer()
                        
                        
                        VStack(spacing: 10) {
                            Text("CLASIFICACION GLOBAL DE SABELOTODOS")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.bottom, 10)
                                .padding(.top, 35)
                            
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
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
                            
                            List {
                                Section(header: HStack {
                                    Text("POS.").fontWeight(.bold)
                                    Spacer()
                                    Text("NOMBRE").fontWeight(.bold)
                                    Spacer()
                                    Text("CIUDAD").fontWeight(.bold)
                                    Spacer()
                                    Text("FCFA").fontWeight(.bold)
                                }) {
                                    ForEach(userData.users) { user in
                                        NavigationLink(
                                            destination: LeadersProfile(userId: user.id)
                                        ) {
                                            HStack {
                                                FlashingText(text: "\(user.leaderboardPosition)", shouldFlash: user.id == userId)
                                                    .font(.system(size: 12)) // adjust the size as per your needs
                                                Spacer()
                                                FlashingText(text: user.fullname, shouldFlash: user.id == userId)
                                                    .font(.system(size: 12)) // adjust the size as per your needs
                                                Spacer()
                                                FlashingText(text: user.ciudad, shouldFlash: user.id == userId)
                                                    .font(.system(size: 12)) // adjust the size as per your needs
                                                Spacer()
                                                FlashingText(text: "\(user.accumulatedPuntuacion)", shouldFlash: user.id == userId)
                                                    .font(.system(size: 12)) // adjust the size as per your needs
                                            }
                                        }
                                    }
                                    
                                }
                            }
                            .listStyle(InsetGroupedListStyle())
                            .onAppear {
                                userData.fetchUsers()
                                
                            }
                        }
                    }
                }
                .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    struct ClasificacionView_Previews: PreviewProvider {
        static var previews: some View {
            ClasificacionView(userId: "DummyUserId")
        }
    }



