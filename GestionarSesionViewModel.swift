import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDatabase

class GestionarSesionViewModel: ObservableObject {
    
    @Published var usuario: FirebaseAuth.User?
    @Published var estaAutenticado: Bool = false
    @Published var errorDeAutenticacion: Error?
    @Published var muestraAlerta: Bool = false
    @Published var alert: TipoDeAlerta?
    @State private var isUserAuthenticated: Bool = false
    
    
    enum TipoDeAlerta {
        
            case success(String)
            case mistake(String)
        }
    
    enum SessionError: LocalizedError {
        case emptyFields
        case invalidEmailFormat
        case wrongPassword
        case emailNotFound
       

        var errorDescription: String? {
            switch self {
            case .emptyFields:
                return "Rellena ambos campos"
            case .invalidEmailFormat:
                return "Error de formato en el email."
            case .wrongPassword :
                return "Contraseña incorrecta. "
            case .emailNotFound:
                        return "Este email no existe. Corrígelo o crea una cuenta nueva."
          
            }
        }
    }
    
    

    
    
    func loginUsuario(correoElectronico: String, contrasena: String) {
        
        guard validarInputs(correoElectronico: correoElectronico, contrasena: contrasena) else {
            return
        }
       
      
        Auth.auth().signIn(withEmail: correoElectronico, password: contrasena) { [weak self] authResult, error in
            
        
            if let error = error as NSError? {
                self?.estaAutenticado = false
                self?.errorDeAutenticacion = error
                
                if error.code == AuthErrorCode.userNotFound.rawValue {
                    SoundManager.shared.playError()
                    self?.ensenarAlerta(type: .mistake(SessionError.emailNotFound.localizedDescription))
                    SoundManager.shared.playError()
                } else if error.code == AuthErrorCode.wrongPassword.rawValue {
                    SoundManager.shared.playError()
                    self?.ensenarAlerta(type: .mistake(SessionError.wrongPassword.localizedDescription))
                } else {
                    SoundManager.shared.playError()
                    self?.ensenarAlerta(type: .mistake("Error de login. Comprueba email/contraseña"))
                }
                
            } else {
                self?.usuario = authResult?.user
                self?.estaAutenticado = true
                SoundManager.shared.playMagic()
                self?.ensenarAlerta(type: .success("Usuario Conectado"))
                
  
            }

        }
    }

    
    func validarInputs(correoElectronico: String, contrasena: String) -> Bool {
        // Validate that inputs are not empty
        guard !correoElectronico.isEmpty, !contrasena.isEmpty else {
            SoundManager.shared.playError()
            self.errorDeAutenticacion = SessionError.emptyFields
            self.ensenarAlerta(type: .mistake(SessionError.emptyFields.localizedDescription))
            return false
        }
        
        // Validate email format using a simple regex
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        guard emailTest.evaluate(with: correoElectronico) else {
            self.errorDeAutenticacion = SessionError.invalidEmailFormat
            self.ensenarAlerta(type: .mistake(SessionError.invalidEmailFormat.localizedDescription))
            return false
        }
      
        return true
    }
    
    func clearUserData() {
        UserDefaults.standard.removeObject(forKey: "fullname")
        UserDefaults.standard.removeObject(forKey: "highestScore")
        UserDefaults.standard.removeObject(forKey: "currentGameFallos")
    }

    func logoutUsuario() {
            try? Auth.auth().signOut()
            self.estaAutenticado = false
        
        clearUserData()
     

        }
    
  
    
    func ensenarAlerta(type: TipoDeAlerta) {
       self.alert = type
       self.muestraAlerta = true


        }
    }


    
