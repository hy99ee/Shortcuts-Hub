import Combine
import SwiftUDF

enum LoginMutation: Mutation {
    case showRegister(store: LoginStore)
    case showForgot
    
    case login(user: LoginCredentials)

    case registrationCredentials((credentials: LoginCredentialsField, status: InputTextFieldStatus))

    case progressLoginStatus(_ status: ProgressViewStatus)
    case progressRegisterStatus(_ status: ProgressViewStatus)

    case setErrorMessage(_ error: Error?)
}

