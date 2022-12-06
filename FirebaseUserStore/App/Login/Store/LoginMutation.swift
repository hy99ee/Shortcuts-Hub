import Foundation
import Combine

enum LoginMutation: Mutation {
    case showRegister(store: LoginStore)
    case showForgot(store: LoginStore)
    
    case login(user: LoginCredentials)
    case create(user: RegistrationCredentials)
    
    case closeForgot

    case progressLoginStatus(_ status: ProgressViewStatus)
    case progressForgotStatus(_ status: ProgressViewStatus)
    case progressRegisterStatus(_ status: ProgressViewStatus)

    case errorAlert(error: Error)
}

