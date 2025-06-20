import SwiftUI
import AVFAudio

struct ContactanosView: View {
    @Binding var player: AVAudioPlayer?
    @State private var isAnimating: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        ZStack {
            Image("coolbackground")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, spacing: 70) {
                Image("logotrivial")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.top, -180)
                    .frame(width: 200, height: 150)
                
                Text("Para ruegos, preguntas, propuestas, sugerencias, correciones, quejas, insultos amenazas o intimidaciones, contáctanos a través del botón de Whatsapp más abajo intentaremos arreglarlo. Gracias por apoyarnos, saludos.")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                    .padding(.vertical, -150)
                
                Button(action: {
                    SoundManager.shared.playTransitionSound()
                    if let url = URL(string: "https://wa.me/240222780886") {
                        UIApplication.shared.open(url)
                    }
                    
                    withAnimation(Animation.easeInOut(duration: 0.3)) {
                        isAnimating.toggle()
                    }
                }) {
                    Image("whatsapp")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150.0, height: 150.0)
                        .cornerRadius(150)
                        .padding(.top, -100)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 0.5)
                                .repeatForever(autoreverses: true) // Repeat with autoreversal
                        )
                }
                Button {
                    SoundManager.shared.playTransitionSound()
                    presentationMode.wrappedValue.dismiss()
                    
                } label: {
                    Text("VOLVER")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 300, height: 75)
                        .background(Color(hue: 0.69, saturation: 0.89, brightness: 0.706))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 3)
                        )
                        .padding(.top, -60)
                }
            }
        }
        
        
        .onAppear {
            withAnimation {
                isAnimating.toggle()
                
            }
            
        }
    }
    
    struct ContactanosView_Previews: PreviewProvider {
        static var previews: some View {
            ContactanosView(player: .constant(nil))
        }
    }
    
}
