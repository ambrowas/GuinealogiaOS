//
//  ResultadoView.swift
//  Guinealogia
//
//  Created by ELEBI on 5/29/23.
//

import Foundation
import SwiftUI

struct ResultadoView: View {
    @State private var aciertos: Int = 0
    @State private var puntuacion: Int = 0
    
    var body: some View {
        VStack {
            Text("Resultado")
                .font(.largeTitle)
                .bold()
                .padding()
            
            Text("Aciertos: \(aciertos)")
                .font(.title)
                .padding()
            
            Text("Puntuación: \(puntuacion)")
                .font(.title)
                .padding()
            
            // Customize the rest of the view as needed
            
        }
    }
}

struct ResultadoView_Previews: PreviewProvider {
    static var previews: some View {
        ResultadoView()
    }
}
