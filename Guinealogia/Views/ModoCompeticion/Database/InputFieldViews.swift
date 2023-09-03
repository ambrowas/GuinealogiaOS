
import SwiftUI

struct InputFieldsView: View {
    @Binding var fullname: String
    @Binding var email: String
    @Binding var password: String
    @Binding var telefono: String
    @Binding var barrio: String
    @Binding var ciudad: String
    @Binding var pais: String
  
    var body: some View {
        VStack {
            
            SingleInputFieldView(text: $fullname, placeholder: "Nombre")
                .border(Color.black, width: 2)
                .textContentType(.name)
                .autocapitalization(.words)
          
            SingleInputFieldView(text: $email, placeholder: "Email")
                .border(Color.black, width: 2)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.none)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
            
            SecureInputFieldView(text: $password, placeholder: "Contraseña")
                .border(Color.black, width: 2)
                .textContentType(.password)
                
            SingleInputFieldView(text: $telefono, placeholder: "Teléfono")
                .border(Color.black, width: 2)
                .textContentType(.telephoneNumber)
            
            SingleInputFieldView(text: $barrio, placeholder: "Barrio")
                .border(Color.black, width: 2)
                .autocorrectionDisabled()
            
            SingleInputFieldView(text: $ciudad, placeholder: "Ciudad")
                .border(Color.black, width: 2)
                .autocorrectionDisabled()
            
            SingleInputFieldView(text: $pais, placeholder: "País")
                .border(Color.black, width: 2)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 40)
    }
}

struct SingleInputFieldView: View {
    @Binding var text: String
    var placeholder: String
  
    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.bottom, 1)
    }
}

struct SecureInputFieldView: View {
    @Binding var text: String
    var placeholder: String
  
    var body: some View {
        SecureField(placeholder, text: $text)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.bottom, 1)
    }
}

