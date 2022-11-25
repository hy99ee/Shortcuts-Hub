import Foundation

enum LoginAction: Action {
    case openRegister(store: LoginStore)
    case openForgot(store: LoginStore)
    
    case clickLogin(user: LoginCredentials)
    case clickCreate(newUser: RegistrationCredentials)
    case clickForgot(email: String)

    case mockAction
}

