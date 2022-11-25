import Foundation
import Combine

enum LoginMutation: Mutation {
    case showRegister(store: LoginStore)
    case showForgot(store: LoginStore)
    
    case login(user: LoginCredentials)
    case newUser(user: RegistrationCredentials)
    
    case closeForgot

    case errorAlert(error: Error)
    case progressViewStatus(status: ProgressViewStatus)
}

