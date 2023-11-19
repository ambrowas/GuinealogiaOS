import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore

class NuevoUsuarioViewModel: ObservableObject {
    @Published var fullname: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var telefono: String = ""
    @Published var barrio: String = ""
    @Published var ciudad: String = ""
    @Published var pais: String = ""
    @Published var error: NuevoUsuarioError?
    @Published var mostrarAlerta: Bool = false
    @Published var alertaTipo: AlertaTipo?
    @Published var navegarAlPerfil: Bool = false
    var userID: String = ""
    private var questionManager: QuestionManager?

    enum AlertaTipo: Identifiable {
        case exito(message: String)
        case error(message: String)

        var id: String {
            switch self {
            case .exito(let message), .error(let message):
                return message
            }
        }
    }

    enum NuevoUsuarioError: Error, Identifiable {
        case emptyField
        case invalidEmailFormat
        case shortPassword
        case invalidPhoneNumber
        case invalidCharacters
        case signInError(description: String)

        var id: String {
            return localizedDescription
        }

        var localizedDescription: String {
            switch self {
            case .emptyField:
                return "Debes rellenar todos los campos."
            case .invalidEmailFormat:
                return "Formato de email incorrecto."
            case .shortPassword:
                return "La contraseña debe tener al menos 6 caracteres."
            case .invalidPhoneNumber:
                return "El campo teléfono solo puede contener dígitos."
            case .invalidCharacters:
                return "El campo contiene caracteres no permitidos."
            case .signInError(let description):
                return "Error al intentar ingresar: \(description)"
            }
        }
    }

    func crearUsuario() {
        print("Inicio del proceso de creación de usuario.")
        
        // Sanitize user input is assumed to be implemented correctly
        
        // Validate user input
        let validationResult = validarCampos()
        if !validationResult.isValid {
            // Prepare the error message(s)
            let errorMessage = validationResult.errors.map { $0.localizedDescription }.joined(separator: " ")
            
            // Update the alertaTipo to communicate the error(s) to the user
            alertaTipo = .error(message: "Error: \(errorMessage)")
            mostrarAlerta = true  // Trigger the alert
            return
        }
        print("Validación de campos exitosa.")
        
        // Step 3: Continue with user creation if validation passes
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            if let error = error {
                print("Error al crear usuario en Firebase Auth: \(error.localizedDescription)")
                strongSelf.alertaTipo = .error(message: error.localizedDescription)
                strongSelf.mostrarAlerta = true
                return
            }
            
            guard let userID = authResult?.user.uid else {
                print("Error: Failed to obtain a valid user ID from Firebase Auth.")
                strongSelf.alertaTipo = .error(message: "Error: Failed to obtain a valid user ID.")
                strongSelf.mostrarAlerta = true
                return
            }
            print("Usuario creado exitosamente en Firebase Auth.")
            
            // Here you need to instantiate QuestionManager with the required arguments.
            // This is just an example: replace the initialization parameters as needed for your actual app.
            strongSelf.questionManager = QuestionManager(
                realTimeDatabaseReference: Database.database().reference(),
                firestore: Firestore.firestore(),
                userID: userID
            )
            
            // Step 4: Use the QuestionManager to assign a random batch number to the user
            // Step 4: Use the QuestionManager to assign a random batch number to the user
            strongSelf.questionManager?.setNumeroDeBatch(userId: userID) { success, error in
                if let error = error {
                    print("Error setting random batch number: \(error.localizedDescription)")
                    strongSelf.alertaTipo = .error(message: "Error setting random batch number: \(error.localizedDescription)")
                    strongSelf.mostrarAlerta = true
                } else if success {
                    // Call the createTable method of DatabaseManager here:
                    DatabaseManager.shared.createTable() // Assuming DatabaseManager uses a shared instance pattern
                    
                    // Save additional user information in your database method
                    strongSelf.guardarUsuario(userId: userID)
                    // Do any necessary actions on user creation success, like navigation
                    strongSelf.alertaTipo = .exito(message: "Usuario creado correctamente. ¡Bienvenid@!")
                    strongSelf.mostrarAlerta = true
                    strongSelf.navegarAlPerfil = true
                } else {
                    print("Failed to set a random batch number due to an unknown reason.")
                    strongSelf.alertaTipo = .error(message: "Failed to set a random batch number.")
                    strongSelf.mostrarAlerta = true
                }
            }
        }
    }


    private func sanitizeAndSetUserInfo(fullname: String, telefono: String, barrio: String, ciudad: String, pais: String) {
        self.fullname = sanitizeString(fullname)
        self.telefono = sanitizeString(telefono)
        self.barrio = sanitizeString(barrio)
        self.ciudad = sanitizeString(ciudad)
        self.pais = sanitizeString(pais)
        // Email is not sanitized to maintain format
        print("Sanitización completada para: nombre completo, teléfono, barrio, ciudad y país.")
    }

    private func guardarUsuario(userId: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let formattedDate = dateFormatter.string(from: Date())

        let userData: [String: Any] = [
            "fullname": self.fullname,
            "email": self.email,
            "telefono": self.telefono,
            "barrio": self.barrio,
            "ciudad": self.ciudad,
            "pais": self.pais,
            "accumulatedAciertos": 0,
            "accumulatedFallos": 0,
            "accumulatedPuntuacion": 0,
            "highestScore": 0,
            "FechadeCreacion": formattedDate
        ]

        let ref = Database.database().reference()
        ref.child("user").child(userId).setValue(userData) { [weak self] error, _ in
            guard let strongSelf = self else { return }

            if let error = error {
                print("Error al guardar datos adicionales del usuario en Firebase: \(error.localizedDescription)")
                strongSelf.error = .signInError(description: error.localizedDescription)
                strongSelf.alertaTipo = .error(message: "Error al guardar datos del usuario: \(error.localizedDescription)")
                strongSelf.mostrarAlerta = true
                return
            }

            print("Datos adicionales del usuario guardados exitosamente en Firebase.")
            strongSelf.IngresarUsuario()
        }
    }

    
    private func validarCampos() -> (isValid: Bool, errors: [NuevoUsuarioError]) {
        var errors = [NuevoUsuarioError]()

        if fullname.isEmpty || email.isEmpty || password.isEmpty || telefono.isEmpty || barrio.isEmpty || ciudad.isEmpty || pais.isEmpty {
            errors.append(.emptyField)
        }

        if !email.isValidEmail {
            errors.append(.invalidEmailFormat)
        }

        if password.count < 6 {
            errors.append(.shortPassword)
        }

        if !telefono.isOnlyDigits {
            errors.append(.invalidPhoneNumber)
        }

        if fullname.isEmpty {
               errors.append(.emptyField)
           }
           
           if email.isEmpty {
               errors.append(.emptyField)
           }
           
           if password.isEmpty {
               errors.append(.emptyField)
           }
           
           if telefono.isEmpty {
               errors.append(.emptyField)
           }
           
           if barrio.isEmpty {
               errors.append(.emptyField)
           }
           
           if ciudad.isEmpty {
               errors.append(.emptyField)
           }
           
           if pais.isEmpty {
               errors.append(.emptyField)
           }

           // Check for invalid email format
           if !email.isValidEmail {
               errors.append(.invalidEmailFormat)
           }

           // Check for invalid characters in fullname, barrio, ciudad, and pais
           if !fullname.isValidName {
               errors.append(.invalidCharacters)
           }
           
           if !barrio.isAlphanumericWithSpaces {
               errors.append(.invalidCharacters)
           }
           
           if !ciudad.isAlphanumericWithSpaces {
               errors.append(.invalidCharacters)
           }
           
           if !pais.isAlphanumericWithSpaces {
               errors.append(.invalidCharacters)
           }

           // Check for password length
           if password.count < 6 {
               errors.append(.shortPassword)
           }

           // Check for digits only in telefono
           if !telefono.isOnlyDigits {
               errors.append(.invalidPhoneNumber)
           }

           return (errors.isEmpty, errors)
       }

    
    
    private func sanitizeString(_ input: String) -> String {
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet.whitespaces).union(CharacterSet(charactersIn: "-."))
        let filteredComponents = input.components(separatedBy: allowedCharacters.inverted)
        return filteredComponents.joined()
    }

    
    private func IngresarUsuario() {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }

            if let error = error {
                strongSelf.error = .signInError(description: error.localizedDescription)
                strongSelf.alertaTipo = .error(message: "Error al ingresar: \(error.localizedDescription)")
                strongSelf.mostrarAlerta = true
                return
            }

            UserDefaults.standard.set(strongSelf.fullname, forKey: "fullname")
            UserDefaults.standard.set(0, forKey: "highestScore")
            UserDefaults.standard.set(0, forKey: "currentGameFallos")
            

            strongSelf.alertaTipo = .exito(message: "Usuario creado correctamente. ¡Bienvenid@!")
            strongSelf.mostrarAlerta = true
            
            strongSelf.navegarAlPerfil = true
        }
    }
}
    
    
  extension String {
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }

    var isOnlyDigits: Bool {
           return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
       }

    var isAlphanumericWithSpaces: Bool {
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet.whitespaces)
        return rangeOfCharacter(from: allowedCharacters.inverted) == nil
    }
    var isValidPhoneNumber: Bool {
        return rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }

    var isValidName: Bool {
        let allowedCharacters = CharacterSet.letters.union(CharacterSet.whitespaces)
        return rangeOfCharacter(from: allowedCharacters.inverted) == nil
    }
}
