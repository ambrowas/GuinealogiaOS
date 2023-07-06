import SwiftUI
import AVFAudio

struct JugarModoLibre: View {
    @StateObject private var quizState = QuizState()
    @State private var showAlert = false
    @State private var isShowingResultadoView = false
    @Binding var player: AVAudioPlayer?
    @State private static var playerName = ""
    
    
    init(player: Binding<AVAudioPlayer?>) {
          _player = player
      }
      


    var body: some View {
        // Inside your body view
        NavigationLink(
            destination: ResultadoView(aciertos: quizState.score, puntuacion: quizState.totalScore, errores: quizState.mistakes),
            isActive: $quizState.isShowingResultadoView
        ) {
            EmptyView()
        }


        ZStack {
            Image("coolbackground")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 5) {
                HStack {
                    Text("ACIERTOS: \(quizState.score)")
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.top, .leading], 50)
                    
                }
                
                HStack {
                    Text("PUNTUACION: \(quizState.totalScore)")
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .padding(.leading, 21.0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                HStack {
                    Text("PREGUNTA: \(quizState.preguntaCounter)/\(quizState.randomQuestions.count)")
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .padding(.leading, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Text("\(quizState.timeRemaining)")
                        .foregroundColor(quizState.timeRemaining <= 5 ? .red : .black)
                        .fontWeight(.bold)
                        .font(.system(size: 60))
                        .padding(.trailing, 20.0)
                        .shadow(color: .black, radius: 1, x: 1, y: 1)
                }
                .padding(.top, -250)
                
                Text(quizState.currentQuestion.question)
                    .foregroundColor(quizState.currentQuestion.textColor) // Set the text color based on the textColor property of currentQuestion
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.top, -120)

                
                VStack(alignment: .leading, spacing: 10) {
                    RadioButton(text: quizState.currentQuestion.option1, selectedOptionIndex: $quizState.selectedOptionIndex, currentQuestion: quizState.currentQuestion)
                    RadioButton(text: quizState.currentQuestion.option2, selectedOptionIndex: $quizState.selectedOptionIndex, currentQuestion: quizState.currentQuestion)
                    RadioButton(text: quizState.currentQuestion.option3, selectedOptionIndex: $quizState.selectedOptionIndex, currentQuestion: quizState.currentQuestion)
                }
                .padding(.bottom, 200)
                
                Button(action: {
                    if quizState.buttonText == "CONFIRMAR" {
                        if quizState.selectedOptionIndex == -1 {
                            showAlert = true
                        } else {
                            quizState.checkAnswer()
                            if quizState.currentQuestionIndex == quizState.randomQuestions.count - 1 {
                                quizState.buttonText = "TERMINAR"
                            } else {
                                quizState.buttonText = "SIGUIENTE"
                            }
                        }
                    } else if quizState.buttonText == "SIGUIENTE" {
                        quizState.showNextQuestion()
                        quizState.buttonText = "CONFIRMAR"
                        quizState.isAnswered = false
                        quizState.selectedOptionIndex = -1
                        quizState.currentQuestion = quizState.randomQuestions[quizState.currentQuestionIndex]
                        quizState.startCountdownTimer()
                    } else if quizState.buttonText == "TERMINAR" {
                        quizState.finishQuiz()
                        quizState.isShowingResultadoView = true
                    }

                }) {
                    Text(quizState.buttonText)
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
                .padding(.top, -180)

            }
            .padding(.horizontal, 12)
        }
        .onAppear {
            quizState.startCountdownTimer()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("ATENCION"),
                message: Text("Sin miedo, escoge una opción"),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $quizState.isShowingResultadoView) {
            ResultadoView(aciertos: quizState.score, puntuacion: quizState.totalScore, errores: quizState.mistakes)
            }
    }
}

struct RadioButton: View {
    var text: String
    @Binding var selectedOptionIndex: Int
    var currentQuestion: QuizQuestion
    
    var body: some View {
        Button(action: {
            selectedOptionIndex = optionIndex
        }) {
            Text(text)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(width: 300, height: 75)
                .background(optionBackground)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 3)
                )
        }
        .onChange(of: selectedOptionIndex) { newValue in
            updateOptionBackground(newValue)
        }
        .onAppear {
            updateOptionBackground(selectedOptionIndex)
        }
    }
    
    private var optionIndex: Int {
        switch text {
        case currentQuestion.option1:
            return 0
        case currentQuestion.option2:
            return 1
        case currentQuestion.option3:
            return 2
        default:
            return -1
        }
    }
    
    @State private var optionBackground: Color = Color(hue: 0.663, saturation: 0.811, brightness: 0.631)
    
    private func updateOptionBackground(_ selectedIndex: Int) {
        if optionIndex == selectedIndex {
            optionBackground = Color(hue: 0.315, saturation: 0.953, brightness: 0.335)
        } else {
            optionBackground = Color(hue: 0.663, saturation: 0.811, brightness: 0.631)
        }
    }
}

struct JugarModoLibre_Previews: PreviewProvider {
    static var previews: some View {
        JugarModoLibre(player: .constant(nil))
    }
}

