
import SwiftUI
import AVFoundation
import Combine
import FirebaseAuth

struct JugarModoCompeticion: View {
    @StateObject private var viewModel: JugarModoCompeticionViewModel
    @State private var showAlert = false
    @State private var hasShownManyMistakesAlert = false
    @State private var navigationTag: Int? = nil
    @State private var userId: String = ""
    @ObservedObject private var userData: UserData
    @State private var shouldPresentGameOver: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @State private var isAlertBeingDisplayed = false
    @State private var showAnswerStatus = false
    @State private var scale: CGFloat = 1.0
    @State private var isGrowing = true
    @State private var showAnswerStatusForMistakes: Bool = false
    
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
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
        // Removed the line that sets activeAlert to nil
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
                
                Text(viewModel.currentQuestion?.questionText ?? "Loading question...")
                    .foregroundColor(.black)
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .lineLimit(nil)
                
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.options.indices, id: \.self) { index in
                        Button(action: {
                            if !viewModel.questionProcessed {
                                viewModel.selectedOptionIndex = index
                                viewModel.resetButtonColors()
                                viewModel.buttonBackgroundColors[index] = Color(hue: 0.315, saturation: 0.953, brightness: 0.335)
                            }
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
                            viewModel.activeAlert = .showAlert
                        } else {
                            viewModel.checkAnswer()
                            showAnswerStatus = true
                            if viewModel.mistakes == 4 && !hasShownManyMistakesAlert {
                                viewModel.activeAlert = .showManyMistakesAlert
                                self.hasShownManyMistakesAlert = true
                            } else if viewModel.mistakes >= 5 {
                                viewModel.activeAlert = .showGameOverAlert
                            }
                            
                        }
                    } else if viewModel.buttonConfirmar == "SIGUIENTE" {
                        showAnswerStatus = false
                        viewModel.questionProcessed = false
                        viewModel.fetchNextQuestion()
                        viewModel.answerChecked = false
                        print("After setting activeAlert: \($viewModel.activeAlert)")
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
                
                
                if viewModel.buttonConfirmar == "SIGUIENTE"{
                    Button(action: {
                        viewModel.triggerEndGameAlert()
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
            if viewModel.answerChecked && viewModel.mistakes < 4 {
                let answerStatus = viewModel.answerIsCorrect ?? false
                Image(systemName: answerStatus ? "checkmark" : "xmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(answerStatus ? .green : .red)
                    .frame(width: 120, height: 120)
                    .scaleEffect(scale)
                    .onReceive(timer) { _ in
                        withAnimation(.easeInOut(duration: 0.5)) {
                            if isGrowing {
                                scale = 1.2
                            } else {
                                scale = 1.0
                            }
                            isGrowing.toggle()
                        }
                    }
                    .transition(.asymmetric(insertion: .scale, removal: .opacity))
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(
                forName: UIApplication.didEnterBackgroundNotification,
                object: nil, queue: .main) { _ in
                    viewModel.appMovedToBackground()
            }

            NotificationCenter.default.addObserver(
                forName: UIApplication.willEnterForegroundNotification,
                object: nil, queue: .main) { _ in
                    viewModel.appReturnsToForeground()
            }

            viewModel.resetButtonColors()
            viewModel.fetchNextQuestion()
        }
        
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .alert(item: $viewModel.activeAlert) { item -> Alert in
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
                
            case .showReturnToAppAlert:
                return Alert(
                    title: Text("Aviso"),
                    message: Text("No debes salir mientras haya una pregunta activa"),
                    dismissButton: .default(Text("OK")) {
                        viewModel.penalizeForLeavingApp() // Process as a wrong answer after dismissing the alert
                    }
                )
            }
            
        }
                .fullScreenCover(isPresented: $shouldPresentGameOver){
                    GameOver(userId: userId)
                        .onDisappear{
                            presentationMode.wrappedValue.dismiss()
                        }
                }
                .onChange(of: viewModel.activeAlert) { newAlert in
                    viewModel.isAlertBeingDisplayed = (newAlert != nil)
                }
                .onDisappear {
                    NotificationCenter.default.removeObserver(
                        self,
                        name: UIApplication.didEnterBackgroundNotification,
                        object: nil
                    )
                    NotificationCenter.default.removeObserver(
                        self,
                        name: UIApplication.willEnterForegroundNotification,
                        object: nil
                    )
                }

                .onReceive(viewModel.timeExpired, perform: { newValue in
                    showAnswerStatusForMistakes = newValue
                    
                })
                
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
    

