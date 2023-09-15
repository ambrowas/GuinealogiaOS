import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var data: Data
    
    var body: some View {
        Image(uiImage: generateQRCodeImage())
            .interpolation(.none)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: 200, maxHeight: 200)
            .border(Color.black, width: 3)
    }
    
    func generateQRCodeImage() -> UIImage {
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        
        filter.setValue(data, forKey: "inputMessage")
        
        if let qrCodeImage = filter.outputImage?.transformed(by: transform),
           let cgImage = context.createCGImage(qrCodeImage, from: qrCodeImage.extent) {
            return UIImage(cgImage: cgImage)
        } else {
            return UIImage(systemName: "xmark.circle") ?? UIImage()
        }
    }
}

struct CodigoQR: View {
    @StateObject var userViewModel = UserViewModel()
    @State var qrData: Data?
    @State var qrCodeKey = ""
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    @Environment (\.presentationMode) var presentationMode
    
    var body: some View {
            ZStack {
                Image("coolbackground")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 10) {
                    if let qrData = qrData {
                        QRCodeView(data: qrData)
                    } else {
                        Text("Generating QR Code...")
                    }
                    
                    Text(qrCodeKey)
                        .foregroundColor(.black)
                        .font(.subheadline)
                        .fontWeight(.bold)
                    
                    VStack(spacing: 10) {
                        Button(action: guardarButtonPressed) {
                            Text("GUARDAR")
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
                        
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("VOLVER")
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
                }
                .onAppear {
                    if let userId = Auth.auth().currentUser?.uid {
                        self.userViewModel.fetchUserData(userId: userId) {
                            self.qrCodeKey = self.generateQRCodeKey()
                            self.qrData = self.generateQRCodeData()
                        }
                    }
                }
                .alert(isPresented: $isShowingAlert) {
                    Alert(title: Text("Resultado"),
                          message: Text(alertMessage),
                          dismissButton: .default(Text("OK")))
                }
            }
        }
        
        func generateQRCodeKey() -> String {
            let allowedCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            let length = 18
            
            var randomKey = ""
            
            for _ in 0..<length {
                let randomIndex = allowedCharacters.index(allowedCharacters.startIndex, offsetBy: Int.random(in: 0..<allowedCharacters.count))
                let character = allowedCharacters[randomIndex]
                randomKey.append(character)
            }
            
            return randomKey
        }
        
        func generateQRCodeData() -> Data? {
            guard let userId = Auth.auth().currentUser?.uid else {
                return nil
            }
            
            let qrCodeData: [String: Any] = [
                "base64QRCode": "iVBORw0KGgoAAAANSUhEUgAA",
                "lastGamePuntuacion": userViewModel.currentGamePuntuacion,
                "lastGameScore": userViewModel.currentGameAciertos,
                "qrCodeKey": qrCodeKey,
                "timestamp": generateCurrentTimestamp(),
                "userId": userId,
                "fullname": userViewModel.fullname,
                "email": userViewModel.email
            ]
            
            if let qrCodeDataString = try? JSONSerialization.data(withJSONObject: qrCodeData) {
                return "\(qrCodeKey),\(String(data: qrCodeDataString, encoding: .utf8) ?? "")".data(using: .utf8)
            } else {
                return nil
            }
        }
        
        func guardarButtonPressed() {
            guard let userId = Auth.auth().currentUser?.uid else {
                return
            }
            
            let qrCodeData: [String: Any] = [
                "base64QRCode": "iVBORw0KGgoAAAANSUhEUgAA",
                "lastGamePuntuacion": userViewModel.currentGamePuntuacion,
                "lastGameScore": userViewModel.currentGameAciertos,
                "qrCodeKey": qrCodeKey,
                "timestamp": generateCurrentTimestamp(),
                "userId": userId,
                "fullname": userViewModel.fullname,
                "email": userViewModel.email
            ]
            
            let ref = Database.database().reference(withPath: "qrCodes").child(userId)
            ref.setValue(qrCodeData) { error, _ in
                if error == nil {
                    isShowingAlert = true
                    alertMessage = "Codigo QR Guardado. Ya puedes ir a cobrar."
                } else {
                    isShowingAlert = true
                    alertMessage = "Error al guardar código."
                }
            }
        }
        
        
        func generateCurrentTimestamp() -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
            return dateFormatter.string(from: Date())
        }
    }
        
        struct CodigoQR_Previews: PreviewProvider {
            static var previews: some View {
                CodigoQR()
            }
        }
        
    

