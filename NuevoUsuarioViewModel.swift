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
    @Published var selectedCountry: String = ""
    @Published var selectedDevice: String = "Android"
    @Published var error: NuevoUsuarioError?
    @Published var mostrarAlerta: Bool = false
    @Published var alertaTipo: AlertaTipo?
    @Published var navegarAlPerfil: Bool = false
    @Published var searchText = ""
    var userID: String = ""
    private var questionManager: QuestionManager?
    @Published var isCountrySelected: Bool = false

  
    
   
    private enum FieldType {
          case name, address, phoneNumber, email, password
      }


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
        case emptyField(fieldName: String)
        case invalidEmailFormat
        case shortPassword
        case invalidPhoneNumber
        case invalidCharacters(fieldName: String)
        case signInError(description: String)

        var id: String {
            return localizedDescription
        }

        var localizedDescription: String {
            switch self {
            case .emptyField(let fieldName):
                SoundManager.shared.playError()
                return "\(fieldName) no debe estar vacío."
            case .invalidEmailFormat:
                SoundManager.shared.playError()
                return "Formato de email incorrecto."
            case .shortPassword:
                SoundManager.shared.playError()
                return "La contraseña debe tener al menos 6 caracteres."
            case .invalidPhoneNumber:
                SoundManager.shared.playError()
                return "Número de teléfono inválido."
            case .invalidCharacters(let fieldName):
                SoundManager.shared.playError()
                return "\(fieldName) contiene caracteres no permitidos."
            case .signInError(let description):
                SoundManager.shared.playError()
                return "Error al intentar ingresar: \(description)"
            }
        }
    }
    
    init() {
            let realTimeDatabaseReference = Database.database().reference()
            let firestore = Firestore.firestore()
            self.userID = Auth.auth().currentUser?.uid ?? "UnknownUserID" // Default value if not logged in
            self.questionManager = QuestionManager(realTimeDatabaseReference: realTimeDatabaseReference, firestore: firestore, userID: userID)
        }


    func crearUsuario() {
        print("Inicio del proceso de creación de usuario.")
        
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
        
        // Proceed with Firebase user creation
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            if let error = error {
                SoundManager.shared.playError()
                print("Error al crear usuario en Firebase Auth: \(error.localizedDescription)")
                strongSelf.alertaTipo = .error(message: error.localizedDescription)
                strongSelf.mostrarAlerta = true
                return
            }
            
            guard let userID = authResult?.user.uid else {
                SoundManager.shared.playError()
                print("Error: Failed to obtain a valid user ID from Firebase Auth.")
                strongSelf.alertaTipo = .error(message: "Error: Failed to obtain a valid user ID.")
                strongSelf.mostrarAlerta = true
                return
            }
            print("Usuario creado exitosamente en Firebase Auth.")

            // Save additional user information
            strongSelf.guardarUsuario(userId: userID)

            // Show success alert and navigate to profile setup
            SoundManager.shared.playMagic()
            strongSelf.alertaTipo = .exito(message: "Usuario creado correctamente. Establece una foto de perfil")
            strongSelf.mostrarAlerta = true
            strongSelf.navegarAlPerfil = true
        }
    }

    private func guardarUsuario(userId: String) {
        // Define date format and get the current formatted date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let formattedDate = dateFormatter.string(from: Date())

        // Prepare user data for saving
        let userData: [String: Any] = [
            "fullname": fullname,
            "email": email,
            "telefono": telefono,
            "barrio": barrio,
            "ciudad": ciudad,
            "pais": selectedCountry, //  Use selected country
            "dispositivo": selectedDevice,
            "accumulatedAciertos": 0,
            "accumulatedFallos": 0,
            "accumulatedPuntuacion": 0,
            "highestScore": 0,
            "FechadeCreacion": formattedDate,
            "positionInLeaderboard": 0 
        ]

        // Reference to Firebase database
        let ref = Database.database().reference()

        // Save user data in Firebase
        ref.child("user").child(userId).setValue(userData) { [weak self] error, _ in
            guard let self = self else { return }

            // Handle any error during saving
            if let error = error {
                print("Error al guardar datos adicionales del usuario en Firebase: \(error.localizedDescription)")
                self.error = .signInError(description: error.localizedDescription)
                self.alertaTipo = .error(message: "Error al guardar datos del usuario: \(error.localizedDescription)")
                self.mostrarAlerta = true
                return
            }

            print("Datos adicionales del usuario guardados exitosamente en Firebase.")

            // Set user default values
            UserDefaults.standard.set(self.fullname, forKey: "fullname")
            UserDefaults.standard.set(0, forKey: "highestScore")
            UserDefaults.standard.set(0, forKey: "currentGameFallos")
            
            // Create the local table in the database
            let dbManager = DatabaseManager()
            dbManager.createTable()

            // Assign a random batch to the user
            self.questionManager?.setNumeroDeBatch(userId: userId) { success, error in
                if let error = error {
                    print("Error in setNumeroDeBatch: \(error.localizedDescription)")
                    // Handle error in setting batch number
                    return
                }
                if success {
                    print("Batch number successfully set for user.")
                    // Handle successful batch number assignment
                    self.uploadStoredFCMTokenIfNeeded()
                    self.updateUserDeviceTokenInDatabase()
                    
                }
            }
        }
    }
    
    func uploadStoredFCMTokenIfNeeded() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("⚠️ User not logged in, skipping FCM token upload")
            return
        }

        if let fcmToken = UserDefaults.standard.string(forKey: "fcmTokenForDebug") {
            let ref = Database.database().reference()
            ref.child("user").child(userID).updateChildValues(["FCMToken": fcmToken]) { error, _ in
                if let error = error {
                    print("❌ Error saving FCM token to database: \(error.localizedDescription)")
                } else {
                    print("✅ Stored FCM token successfully saved to database for user ID: \(userID)")
                    UserDefaults.standard.removeObject(forKey: "fcmTokenForDebug")
                }
            }
        } else {
            print("⚠️ No stored FCM token found to upload")
        }
    }
 
    func updateUserDeviceTokenInDatabase() {
        if let userID = Auth.auth().currentUser?.uid,
           let token = UserDefaults.standard.string(forKey: "deviceToken") {
            let ref = Database.database().reference()
            ref.child("user").child(userID).updateChildValues(["Token": token]) { error, _ in
                if let error = error {
                    print("Error saving token to database: \(error.localizedDescription)")
                } else {
                    print("Device token successfully saved to database")
                    // Optionally, clear the token from UserDefaults after successful upload
                    UserDefaults.standard.removeObject(forKey: "deviceToken")
                }
            }
        }
    }


    private func validarCampos() -> (isValid: Bool, errors: [NuevoUsuarioError]) {
        var errors = [NuevoUsuarioError]()

        // Check for empty fields with specific field names
        if fullname.isEmpty {
            errors.append(.emptyField(fieldName: "Nombre completo"))
        }
        if email.isEmpty {
            errors.append(.emptyField(fieldName: "Email"))
        }
        if password.isEmpty {
            errors.append(.emptyField(fieldName: "Contraseña"))
        }
        if telefono.isEmpty {
            errors.append(.emptyField(fieldName: "Teléfono"))
        }
        if barrio.isEmpty {
            errors.append(.emptyField(fieldName: "Barrio"))
        }
        if ciudad.isEmpty {
            errors.append(.emptyField(fieldName: "Ciudad"))
        }
        if selectedCountry == "Escoge tu país de residencia" { // Replace with your default or placeholder value
                errors.append(.emptyField(fieldName: "País"))
        }
        if selectedDevice == "Selecciona tu dispositivo" { // Replace with your default or placeholder value
                errors.append(.emptyField(fieldName: "Dispositivo"))
        }

        // Check for invalid email format
        if !email.isValidEmail {
            errors.append(.invalidEmailFormat)
        }

        // Check for password length
        if password.count < 6 {
            errors.append(.shortPassword)
        }

        // Check for valid phone number format
        if !telefono.isValidPhoneNumber {
            errors.append(.invalidPhoneNumber)
        }

        // Check for valid characters in fullname, barrio, ciudad, and pais
        if !fullname.isValidName {
            errors.append(.invalidCharacters(fieldName: "Nombre completo"))
        }
        if !barrio.isLessRestrictiveAlphanumeric {
            errors.append(.invalidCharacters(fieldName: "Barrio"))
        }
        if !ciudad.isLessRestrictiveAlphanumeric {
            errors.append(.invalidCharacters(fieldName: "Ciudad"))
        }
        if !selectedCountry.isLessRestrictiveAlphanumeric {
            errors.append(.invalidCharacters(fieldName: "País"))
        }

        return (errors.isEmpty, errors)
    }
    
    
    private func sanitizeAndSetUserInfo(fullname: String, telefono: String, barrio: String, ciudad: String, pais: String) {
        // Enum to define field types
        enum FieldType {
            case name, address, phoneNumber, email, password
        }

        // Updated calls to sanitizeString with field type
        self.fullname = sanitizeString(fullname, forFieldType: .name)
        self.telefono = sanitizeString(telefono, forFieldType: .phoneNumber)
        self.barrio = sanitizeString(barrio, forFieldType: .address)
        self.ciudad = sanitizeString(ciudad, forFieldType: .address)
      
        // Email is not sanitized to maintain format
        print("Sanitización completada para: nombre completo, teléfono, barrio, ciudad y país.")
    }


    private func sanitizeString(_ input: String, forFieldType type: FieldType) -> String {
        let allowedCharacters: CharacterSet

        switch type {
        case .name, .address:
            // Allow letters, numbers, spaces, punctuation for names and addresses
            allowedCharacters = CharacterSet.letters
                                .union(CharacterSet.decimalDigits)
                                .union(CharacterSet.whitespaces)
                                .union(CharacterSet.punctuationCharacters)
                                .union(CharacterSet(charactersIn: "-.'"))
        case .phoneNumber:
            // For phone numbers, restrict to numbers, plus, hyphen, and spaces
            allowedCharacters = CharacterSet(charactersIn: "+- ")
                                .union(CharacterSet.decimalDigits)
        case .email, .password:
            // For email and password, return input as is
            return input
        }

        let filteredComponents = input.components(separatedBy: allowedCharacters.inverted)
        return filteredComponents.joined()
    }
}
    
   extension String {
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }

    var isValidPhoneNumber: Bool {
        let phoneRegex = "^[+0-9]{1,}[0-9\\-\\s]{3,15}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: self)
    }

    var isValidName: Bool {
        let allowedCharacters = CharacterSet.letters
                               .union(CharacterSet.whitespaces)
                               .union(CharacterSet(charactersIn: "-'"))
                               .union(CharacterSet(charactersIn: "-.'"))
                               .union(CharacterSet.decimalDigits) // If numeric characters are allowed in names
        return rangeOfCharacter(from: allowedCharacters.inverted) == nil
    }

    var isLessRestrictiveAlphanumeric: Bool {
        let allowedCharacters = CharacterSet.letters
                               .union(CharacterSet.decimalDigits)
                               .union(CharacterSet.whitespaces)
                               .union(CharacterSet.punctuationCharacters) // If punctuation is allowed
        return rangeOfCharacter(from: allowedCharacters.inverted) == nil
    }
}

