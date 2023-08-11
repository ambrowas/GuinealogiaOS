////  ContentView.swift
//  Guinealogia
//
//  Created by ELEBI on 5/28/23.
//

import SwiftUI
import AVFoundation
struct ContentView: View {
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0.0
    @State private var player: AVAudioPlayer?
    @State private var isAnimating: Bool = false
    @State private var showNextView = false
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Image("mimosa")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .edgesIgnoringSafeArea(.all)
                    
                    Image("logotrivial")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .scaleEffect(scale)
                        .rotationEffect(.degrees(rotation))
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .onTapGesture {
                            self.showNextView = true
                        }
                }
            }
            .background(
                NavigationLink(
                    destination: MenuPrincipal(player: .constant(nil)),
                    isActive: $showNextView,
                    label: {
                        EmptyView()
                    }
                )
                .hidden()
            )
        }
        .onAppear {
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
            
            if let url = Bundle.main.url(forResource: "maeledjidalot", withExtension: "mp3") {
                do {
                    self.player = try AVAudioPlayer(contentsOf: url)
                    self.player?.play()
                } catch {
                    print("Could not create AVAudioPlayer: \(error)")
                }
            } else {
                print("Could not find URL for audio file")
            }
        }
    }
}

struct NextView: View {
    var body: some View {
        Text("Next View")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 14")
    }
}
