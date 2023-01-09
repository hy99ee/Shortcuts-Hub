import Foundation

enum LoginAction: Action {
    case openRegister(store: LoginStore)
    case openForgot
    
    case clickLogin(user: LoginCredentials)
    case clickCreate(newUser: RegistrationCredentials)

    case mockAction
}

