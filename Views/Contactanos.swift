import SwiftUI
import AVFAudio

struct ContactanosView: View {
    @Binding var player: AVAudioPlayer?
    @State private var isAnimating: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        ZStack {
            Image("tresy")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, spacing: 35) {
                Image("logotrivial")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.top, -80)
                    .frame(width: 200, height: 150)
                
                Text("""
                ¿Tienes preguntas, sugerencias, alguna corrección o idea genial?
                Estamos aquí para escucharte. Pulsa el icono de WhatsApp para contactarnos directamente.
                Ya sea para mejorar, agradecer o simplemente saludar, ¡nos encantará leerte!
                Gracias por ser parte de esta comunidad. 🌍✨
                """)
                .font(.custom("MarkerFelt-Thin", size: 16))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading) // Cleanest option for now
                .padding(.horizontal)
                
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
                        .font(.custom("MarkerFelt-Thin", size: 16))
                        .foregroundColor(.black)
                        .frame(width: 300, height: 75)
                        .background(Color.pastelSilver)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 3)
                        )
                        .padding(.top, -20)
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
