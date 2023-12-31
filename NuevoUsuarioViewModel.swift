import SwiftUI
import Combine
import Foundation
import FirebaseAuth
import Firebase
import FirebaseDatabase
import Combine
import SwiftUI
import FirebaseFirestore

class NuevoUsuarioViewModel: ObservableObject {
    @Published var fullname: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var telefono: String = ""
    @Published var barrio: String = ""
    @Published var ciudad: String = ""
    @Published var pais: String = ""
    private var db = Firestore.firestore()
    @Published var error: NuevoUsuarioError?
    @Published var mostrarAlerta: Bool = false
    @Published var alertaTipo: AlertaTipo?
    @Published var navegarAlPerfil: Bool = false
    var userID: String
    var questionManager: QuestionManager

    init() {
        let realTimeDatabaseReference = Database.database().reference()
        let firestore = Firestore.firestore()
        self.userID = Auth.auth().currentUser?.uid ?? "UnknownUserID" // Default value if not logged in
        self.questionManager = QuestionManager(realTimeDatabaseReference: realTimeDatabaseReference, firestore: firestore, userID: userID)
    }


    
    
    enum AlertaTipo: Identifiable {
            var id: String {
                switch self {
                case .exito(let message), .error(let message):
                    return message
                }
            }
            
            case exito(message: String)
            case error(message: String)
        }
        
    
    enum NuevoUsuarioError: Error, Identifiable {
        var id: String { localizedDescription }
        
        case emptyField
        case invalidEmailFormat
        case shortPassword
        case invalidPhoneNumber
        case signInError(description: String)
        
        var localizedDescription: String {
            switch self {
            case .emptyField:
                return "Debes rellenar todos los campos."
            case .invalidEmailFormat:
                return "Formato de email incorrecto"
            case .shortPassword:
                return "La contrasena debe tener 6 carateres por lo menos."
            case .invalidPhoneNumber:
                return "El campo teléfono solo puede contener digitos."
            case.signInError:
                return "Error al intentar ingresar"
            }
        }
    }
    
    func crearUsuario() {
        guard validarCampos() else { return }
          
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
                self.alertaTipo = .error(message: error.localizedDescription)
                self.mostrarAlerta = true
                return
            }
            
            // Successfully created user, now add additional details in Firestore
            self.guardarUsuario(userId: authResult?.user.uid ?? "")
        }
    }
    
    private func guardarUsuario(userId: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yy"
        let currentDateTime = Date()
        let formattedDate = dateFormatter.string(from: currentDateTime)

        let userData: [String: Any] = [
            "fullname": fullname,
            "email": email,
            "password": password,
            "telefono": telefono,
            "barrio": barrio,
            "ciudad": ciudad,
            "pais": pais,
            "accumulatedAciertos": 0,
            "accumulatedFallos": 0,
            "accumulatedPuntuacion": 0,
            "highestScore": 0,
            "FechadeCreacion": formattedDate // Here we add the formatted date and time
        ]
            UserDefaults.standard.set(fullname, forKey: "fullname")
           UserDefaults.standard.set(0, forKey: "highestScore")
           UserDefaults.standard.set(0, forKey: "currentGameFallos")
        
            
            // You can log the userData dictionary before sending it to Firestore
            print("UserData: \(userData)")
            
        let ref = Database.database().reference()
        ref.child("user").child(userId).setValue(userData) { error, ref in
            if let error = error {
                print("Data could not be saved: \(error).")
                self.alertaTipo = .error(message: error.localizedDescription)
                self.mostrarAlerta = true
                return
            }
            print("Data saved successfully!")
            let dbManager = DatabaseManager()
                       dbManager.createTable()
            self.IngresarUsuario()
        }

        }

    
    func validarCampos() -> Bool {
        // Check that no field is empty
        guard !fullname.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              !telefono.isEmpty,
              !barrio.isEmpty,
              !ciudad.isEmpty,
              !pais.isEmpty else {
            mostrarError(.emptyField)
            return false
        }
        
        // Check that email matches the regex for valid email format
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: email) else {
            mostrarError(.invalidEmailFormat)
            return false
        }
        
        // Check that password is at least 6 characters long
        guard password.count >= 6 else {
            mostrarError(.shortPassword)
            return false
        }
        
        // Check that telefono contains only digits
        let digitSet = CharacterSet.decimalDigits
        guard telefono.rangeOfCharacter(from: digitSet.inverted) == nil else {
            mostrarError(.invalidPhoneNumber)
            return false
        }
        
        return true
    }
    
    func mostrarError(_ error: NuevoUsuarioError) {
        self.error = error
        self.alertaTipo = .error(message: error.localizedDescription)
        self.mostrarAlerta = true
        }
    
    func IngresarUsuario() {
           Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
               guard let strongSelf = self else { return }
               
               if let error = error {
                   // Handle sign-in error
                   strongSelf.mostrarError(.signInError(description: error.localizedDescription))
                   return
               }
               
               // Ensure a valid user ID is retrieved
               guard let userID = authResult?.user.uid else {
                   // Handle error: failed to get user ID
                   return
               }
               
               // Set UserDefaults for this session
               UserDefaults.standard.set(strongSelf.fullname, forKey: "fullname")
               UserDefaults.standard.set(0, forKey: "highestScore")
               UserDefaults.standard.set(0, forKey: "currentGameFallos")
               
               // Assign a random batch to the user
               strongSelf.questionManager.countTotalBatches { totalBatches in
                   guard totalBatches > 0 else {
                       // Handle error: no batches available
                       return
                   }
                   
                   // Generate a random batch number and set it for the user
                   let randomBatchNumber = Int.random(in: 1...totalBatches)
                   strongSelf.questionManager.setNumeroDeBatch(userId: userID) { success, error in
                       if let error = error {
                           // Handle error in setting batch number
                           return
                       }
                       if success {
                           
                       }
                   }
               }
               
               // Success message for sign-in (not dependent on the batch assignment)
               strongSelf.alertaTipo = .exito(message: "Usuario Creado. Completa tu perfil agregando una foto.")
               strongSelf.mostrarAlerta = true
           }
       }
    
   
    

    
}

