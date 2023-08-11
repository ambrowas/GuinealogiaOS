import SwiftUI
import AVFoundation
import Combine
import FirebaseAuth

struct JugarModoCompeticion: View {
    @StateObject private var viewModel: JugarModoCompeticionViewModel
    @State private var showAlert = false
    @State private var activeAlert: ActiveAlert?
    @State private var hasShownManyMistakesAlert = false
    @State private var navigationTag: Int? = nil
    @State private var userId: String = ""
    @ObservedObject private var userData: UserData
    @State private var shouldPresentGameOver: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    
    enum ActiveAlert: Identifiable {
        case showAlert, showEndGameAlert, showGameOverAlert, showManyMistakesAlert
        
        var id: Int {
            switch self {
            case .showAlert:
                return 0
            case .showEndGameAlert:
                return 1
            case .showGameOverAlert:
                return 2
            case .showManyMistakesAlert:
                return 3
            }
        }
    }
    
    init(userId: String, userData: UserData) {
        
        _viewModel = StateObject(wrappedValue: JugarModoCompeticionViewModel(userId: userId, userData: userData))
        self.userData = userData
        
        //        _viewModel = StateObject(wrappedValue: JugarModoCompeticionViewModel(userId: userId, userData: userData))
        //        self.userData = userData
        
    }
    
    var body: some View {
        ZStack {
            Image("coolbackground")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("ACIERTOS:")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .padding(.leading, 20)
                        
                        Text("FALLOS:")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .padding(.leading, 20)
                        
                        Text("PUNTUACION:")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .padding(.leading, 20)
                    }
                    .padding(.top, -25)
                    
                    VStack(alignment: .leading) {
                        Text("\(viewModel.score)")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .padding(.leading, 20)
                        
                        Text("\(viewModel.mistakes)")
                            .foregroundColor(viewModel.mistakes >= 4 ? .red : .black)
                            .fontWeight(.bold)
                            .padding(.leading, 20)
                        
                        Text("\(viewModel.totalScore)")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .padding(.leading, 20)
                    }
                    .padding(.top, -20)
                    
                    Spacer()
                    
                    Text("\(viewModel.timeRemaining)")
                        .foregroundColor(viewModel.timeRemaining <= 10 ? .red : .black)
                        .fontWeight(.bold)
                        .font(.system(size: 60))
                        .padding(.trailing, 20)
                        .shadow(color: .black, radius: 1, x: 1, y: 1)
                        .padding(.top, -20)
                }
                
                if let imageURL = URL(string: viewModel.image) {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .padding(.top, -25)
                    } placeholder: {
                        Image("logotrivial")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .padding(.top, -25)
                    }
                }
                
                Text(viewModel.category)
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .padding(.top, -20)
                
                Text(viewModel.currentQuestion)
                    .foregroundColor(.black)
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .lineLimit(nil)
                
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.options.indices, id: \.self) { index in
                        Button(action: {
                            viewModel.selectedOptionIndex = index
                            viewModel.resetButtonColors()
                            viewModel.buttonBackgroundColors[index] = Color(hue: 0.315, saturation: 0.953, brightness: 0.335)
                        }) {
                            Text(viewModel.options[index])
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 300, height: 75)
                                .background(viewModel.buttonBackgroundColors.indices.contains(index) ? viewModel.buttonBackgroundColors[index] : Color.clear)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 3)
                                )
                        }
                    }
                }
                
                Button(action: {
                    if viewModel.buttonConfirmar == "CONFIRMAR" {
                        if viewModel.selectedOptionIndex == nil {
                            self.activeAlert = .showAlert
                        } else {
                            viewModel.checkAnswer()
                            if viewModel.mistakes == 4 && !hasShownManyMistakesAlert {
                                self.activeAlert = .showManyMistakesAlert
                                self.hasShownManyMistakesAlert = true
                            } else if viewModel.mistakes >= 5 {
                                self.activeAlert = .showGameOverAlert
                            }
                        }
                    } else if viewModel.buttonConfirmar == "SIGUIENTE" {
                        viewModel.fetchNextQuestion()
                    }
                }) {
                    Text(viewModel.buttonConfirmar)
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(width: 300, height: 75)
                        .background(Color(.white))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 3)
                        )
                }
                
                if viewModel.buttonConfirmar == "SIGUIENTE" {
                    Button(action: {
                        self.activeAlert = .showEndGameAlert
                        print("============\(activeAlert)=============")
                    }) {
                        Text("TERMINAR")
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
                }
            }
            if viewModel.answerChecked {
                if viewModel.answerIsCorrect ?? false {
                    Image(systemName: "checkmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.green)
                        .frame(width: 100, height: 100)
                        .transition(.asymmetric(insertion: .scale, removal: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation {
                                    viewModel.answerChecked = false
                                }
                            }
                        }
                } else {
                    Image(systemName: "xmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.red)
                        .frame(width: 100, height: 100)
                        .transition(.asymmetric(insertion: .scale, removal: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation {
                                    viewModel.answerChecked = false
                                }
                            }
                        }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: viewModel.fetchQuestion)
        .alert(item: $activeAlert) { item in
            switch item {
            case .showAlert:
                return Alert(title: Text("ATENCION"), message: Text("Sin miedo, escoge una opción."), dismissButton: .default(Text("OK")))
                
            case .showEndGameAlert:
                print("Show End Game Alert")
                return Alert(
                    title: Text("Confirmación"),
                    message: Text("¿Seguro que quieres terminar la partida?"),
                    primaryButton: .destructive(Text("SI")) {
                        viewModel.terminar {
                            shouldPresentGameOver = true
                        }
                    },
                    secondaryButton: .cancel(Text("NO"))
                )
                
                
            case .showGameOverAlert:
                return Alert(
                    title: Text("Game Over"),
                    message: Text("Has cometido 5 errores. Fin de la partida."),
                    dismissButton: .default(Text("OK")) {
                        viewModel.terminar {
                            shouldPresentGameOver = true
                        }
                    }
                )
                
                
            case .showManyMistakesAlert:
                return Alert(title: Text("Cuidado"), message: Text("Llevas 4 fallos. Uno más y la partida se acaba."), dismissButton: .default(Text("OK")))
            }
        }
        .fullScreenCover(isPresented: $shouldPresentGameOver){
            GameOver(userId: userId)
                .onDisappear{
                    presentationMode.wrappedValue.dismiss()
                }
        }
    }
}
 

struct GameOverPresented: Identifiable {
    var id = UUID() // changes
}

struct JugarModoCompeticion_Previews: PreviewProvider {
    static var previews: some View {
        JugarModoCompeticion(userId: "DummyuserId", userData: UserData())
    }
}
