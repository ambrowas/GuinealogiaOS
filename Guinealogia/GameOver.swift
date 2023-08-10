import SwiftUI

struct GameOver: View {
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0.0
    @State private var isAnimating: Bool = false
    @Environment(\.presentationMode) var presentationMode

    var userId: String
    
    var body: some View {
        ZStack {
            Image("mimosa")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("GAME OVER")
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .scaleEffect(scale)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                }

                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            print("GameOver screen appeared")

            withAnimation(Animation.easeInOut(duration: 3.0)) {
                self.scale = 3.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(Animation.linear(duration: 1.0)) {
                    self.rotation = 360.0
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(Animation.easeInOut(duration: 3.0)) {
                        self.scale = 2.0

                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                self.isAnimating = true
                            }
                        }
                    }
                }
            }
        }
        .onDisappear {
            print("GameOver screen disappeared")
        }
        .navigationBarBackButtonHidden(true)
    }
}



struct GameOver_Previews: PreviewProvider {
    static var previews: some View {
        GameOver(userId: "dummyUserId")
    }
}

