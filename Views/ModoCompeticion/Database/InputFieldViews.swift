import SwiftUI

struct InputFieldsView: View {
    @Binding var fullname: String
    @Binding var email: String
    @Binding var password: String
    @Binding var telefono: String
    @Binding var barrio: String
    @Binding var ciudad: String
    @Binding var selectedCountry: String
    @Binding var selectedDevice: String
    @State private var isPresentingCountryPicker = false
    
    @State private var countrySearchTerm = ""
    @ObservedObject var viewModel: NuevoUsuarioViewModel // Observed ViewModel
    
    
    
    let countries = [
        "Afganistán", "Albania", "Alemania", "Andorra", "Angola",
        "Antigua y Barbuda", "Arabia Saudita", "Argelia", "Argentina", "Armenia",
        "Australia", "Austria", "Azerbaiyán", "Bahamas", "Bangladés",
        "Barbados", "Baréin", "Bélgica", "Belice", "Benín",
        "Bielorrusia", "Birmania", "Bolivia", "Bosnia y Herzegovina", "Botsuana",
        "Brasil", "Brunéi", "Bulgaria", "Burkina Faso", "Burundi",
        "Bután", "Cabo Verde", "Camboya", "Camerún", "Canadá",
        "Catar", "Chad", "Chile", "China", "Chipre",
        "Ciudad del Vaticano", "Colombia", "Comoras", "Corea del Norte", "Corea del Sur",
        "Costa de Marfil", "Costa Rica", "Croacia", "Cuba", "Dinamarca",
        "Dominica", "Ecuador", "Egipto", "El Salvador", "Emiratos Árabes Unidos",
        "Eritrea", "Eslovaquia", "Eslovenia", "España", "Estados Unidos",
        "Estonia", "Etiopía", "Filipinas", "Finlandia", "Fiyi",
        "Francia", "Gabón", "Gambia", "Georgia", "Ghana",
        "Granada", "Grecia", "Guatemala", "Guinea", "Guinea-Bisáu",
        "Guinea Ecuatorial", "Guyana", "Haití", "Honduras", "Hungría",
        "India", "Indonesia", "Irak", "Irán", "Irlanda",
        "Islandia", "Islas Marshall", "Islas Salomón", "Israel", "Italia",
        "Jamaica", "Japón", "Jordania", "Kazajistán", "Kenia",
        "Kirguistán", "Kiribati", "Kuwait", "Laos", "Lesoto",
        "Letonia", "Líbano", "Liberia", "Libia", "Liechtenstein",
        "Lituania", "Luxemburgo", "Macedonia del Norte", "Madagascar", "Malasia",
        "Malaui", "Maldivas", "Malí", "Malta", "Marruecos",
        "Mauricio", "Mauritania", "México", "Micronesia", "Moldavia",
        "Mónaco", "Mongolia", "Montenegro", "Mozambique", "Namibia",
        "Nauru", "Nepal", "Nicaragua", "Níger", "Nigeria",
        "Noruega", "Nueva Zelanda", "Omán", "Países Bajos", "Pakistán",
        "Palaos", "Palestina", "Panamá", "Papúa Nueva Guinea", "Paraguay",
        "Perú", "Polonia", "Portugal", "Reino Unido", "República Centroafricana",
        "República Checa", "República del Congo", "República Democrática del Congo", "República Dominicana", "Ruanda",
        "Rumanía", "Rusia", "Samoa", "San Cristóbal y Nieves", "San Marino",
        "San Vicente y las Granadinas", "Santa Lucía", "Santo Tomé y Príncipe", "Senegal", "Serbia",
        "Seychelles", "Sierra Leona", "Singapur", "Siria", "Somalia",
        "Sri Lanka", "Suazilandia", "Sudáfrica", "Sudán", "Sudán del Sur",
        "Suecia", "Suiza", "Surinam", "Tailandia", "Tanzania",
        "Tayikistán", "Timor Oriental", "Togo", "Tonga", "Trinidad y Tobago",
        "Túnez", "Turkmenistán", "Turquía", "Tuvalu", "Ucrania",
        "Uganda", "Uruguay", "Uzbekistán", "Vanuatu", "Venezuela",
        "Vietnam", "Yemen", "Yibuti", "Zambia", "Zimbabue"
    ]
    
    let devices = ["Android", "Apple"]
    
    
    
    var body: some View {
        VStack(alignment: .leading) {
            SingleInputFieldView(text: $fullname, placeholder: "Nombre")
                .border(Color.black, width: 2)
                .textContentType(.name)
                .autocapitalization(.words)
                .background(Color.white)
                .padding(.horizontal, 20)
            
            SingleInputFieldView(text: $email, placeholder: "Email")
                .border(Color.black, width: 2)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.none)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .background(Color.white)
                .padding(.horizontal, 20)
            
            SecureInputFieldView(text: $password, placeholder: "Contraseña")
                .border(Color.black, width: 2)
                .background(Color.white)
                .padding(.horizontal, 20)
            
            SingleInputFieldView(text: $telefono, placeholder: "Teléfono")
                .border(Color.black, width: 2)
                .background(Color.white)
                .padding(.horizontal, 20)
            
            SingleInputFieldView(text: $barrio, placeholder: "Barrio")
                .border(Color.black, width: 2)
                .autocorrectionDisabled()
                .background(Color.white)
                .padding(.horizontal, 20)
            
            SingleInputFieldView(text: $ciudad, placeholder: "Ciudad")
                .border(Color.black, width: 2)
                .autocorrectionDisabled()
                .background(Color.white)
                .padding(.horizontal, 20)
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 5) {
                    // Button for selecting country
                    Button("País:") {
                        isPresentingCountryPicker = true
                    }
                    .foregroundColor(.blue)
                    
              

                    // Placeholder showing selected country
                    Text(selectedCountry.isEmpty ? "" : selectedCountry)
                        .onTapGesture {
                            isPresentingCountryPicker = true
                        }
                        .foregroundColor(.gray)
                        .frame(width: 160, height: 30)
                        .border(Color.black, width: 2)
                        .background(Color.white)
                    
                    // Sheet for country picker
                    .sheet(isPresented: $isPresentingCountryPicker) {
                        CountryPickerView(selectedCountry: $selectedCountry, countrySearchTerm: $countrySearchTerm, countries: countries)
                    }
                }
                .padding(.horizontal, 20)
                .environment(\.colorScheme, .light)

                // Device Picker
                VStack(spacing: 5) {
                    Text("Dispositivo:")
                        .foregroundColor(.gray)
                        .padding(.horizontal, -80)
                    Picker("Dispositivo", selection: $selectedDevice) {
                        ForEach(devices, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 160)
                    .border(Color.black, width: 2)
                    .background(Color.white)
                }
                .padding(.horizontal, 0)
            }
            .environment(\.colorScheme, .light)


                
                
            }
        }
    }
        
        struct SingleInputFieldView: View {
            @Binding var text: String
            var placeholder: String
            var onTextChange: ((String) -> Void)?
            
            var body: some View {
                TextField(placeholder, text: $text)
                    .onChange(of: text, perform: { newValue in
                        onTextChange?(newValue)
                    })
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
        
struct CountryPickerView: View {
    @Binding var selectedCountry: String
    @Binding var countrySearchTerm: String
    let countries: [String]

    @Environment(\.presentationMode) var presentationMode

    var filteredCountries: [String] {
        if countrySearchTerm.isEmpty {
            return countries
        } else {
            return countries.filter { $0.localizedCaseInsensitiveContains(countrySearchTerm) }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background image
                Image("coolbackground")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)

                // List of countries
                List(filteredCountries, id: \.self) { country in
                    Text(country)
                        .onTapGesture {
                            selectedCountry = country
                            presentationMode.wrappedValue.dismiss() // Dismiss the view
                        }
                }
                .searchable(text: $countrySearchTerm, prompt: "Buscar país")
            }
            .navigationBarTitle("Seleccionar País", displayMode: .inline)
        }
    }
}

            
            struct InputFieldsView_Previews: PreviewProvider {
                static var previews: some View {
                    InputFieldsView(
                        fullname: .constant("John Doe"),
                        email: .constant("johndoe@example.com"),
                        password: .constant("password123"),
                        telefono: .constant("123-456-7890"),
                        barrio: .constant("Downtown"),
                        ciudad: .constant("New York"),
                        selectedCountry: .constant("United States"),
                        selectedDevice: .constant("Android"),
                        viewModel: NuevoUsuarioViewModel() // instantiate view model for the preview
                    )
                }
            }
            
        
    

