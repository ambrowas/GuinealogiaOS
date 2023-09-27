
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
                .background(Color.white)
          
            SingleInputFieldView(text: $email, placeholder: "Email")
                .border(Color.black, width: 2)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.none)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .background(Color.white)
              
                
            
            SecureInputFieldView(text: $password, placeholder: "Contraseña")
                .border(Color.black, width: 2)
                .background(Color.white)
                
            SingleInputFieldView(text: $telefono, placeholder: "Teléfono")
                .border(Color.black, width: 2)
                .background(Color.white)
            
            SingleInputFieldView(text: $barrio, placeholder: "Barrio")
                .border(Color.black, width: 2)
                .autocorrectionDisabled()
                .background(Color.white)
            
            SingleInputFieldView(text: $ciudad, placeholder: "Ciudad")
                .border(Color.black, width: 2)
                .autocorrectionDisabled()
                .background(Color.white)
            
            SingleInputFieldView(text: $pais, placeholder: "País")
                .border(Color.black, width: 2)
                .autocorrectionDisabled()
                .background(Color.white)
        }
        .padding(.horizontal, 40)
        .environment(\.colorScheme, .light)
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

