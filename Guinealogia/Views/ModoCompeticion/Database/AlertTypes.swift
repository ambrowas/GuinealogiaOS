import SwiftUI

enum AlertType: Identifiable {
    case userCreated, error
    
    var id: Int {
        switch self {
        case .userCreated:
            return 1
        case .error:
            return 2
        }
    }
}

