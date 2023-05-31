import SwiftUI

struct MenuModoLibre: View {
    @State private var playerName = ""
    @State private var showAlert = false
    @State private var isPresented = false
    @State private var jugarModoLibreActive = false
    
    var body: some View {
        ZStack {
            Image("coolbackground")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Image("logotrivial")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.top, 15)
                    .frame(width: 200, height: 150)
                
                TextField("INTRODUCE TU NOMBRE", text: $playerName)
                    .foregroundColor(.black)
                    .font(.system(size: 8))
                    .frame(width: 200, height: 50)
                    .padding(.top, 50)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    savePlayerName()
                    showAlert = true
                }) {
                    Text("GUARDAR")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .multilineTextAlignment(.center)
                        .background(Color(hue: 0.664, saturation: 0.935, brightness: 0.604))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 3)
                        )
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Bienvenid@ \(playerName)"),
                        dismissButton: .default(Text("OK"))
                    )
                }
                
                Button(action: {
                    jugarModoLibreActive = true
                }) {
                    Text("JUGAR")
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
                .onTapGesture {
                    jugarModoLibreActive.toggle()
                }
                .sheet(isPresented: $jugarModoLibreActive, content: {
                    JugarModoLibre()
                })
                
                Button(action: {
                    isPresented.toggle()
                }) {
                    Text("SALIR")
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
                .sheet(isPresented: $isPresented, content: {
                    MenuPrincipal()
                })
                
                Spacer()
            }
        }
    }
    
    private func savePlayerName() {
        // Save player name logic
    }
}

struct MenuModoLibre_Previews: PreviewProvider {
    static var previews: some View {
        MenuModoLibre()
    }
}
