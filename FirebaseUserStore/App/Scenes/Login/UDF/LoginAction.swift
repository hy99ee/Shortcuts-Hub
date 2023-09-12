import SwiftUDF

enum LoginAction: Action, Hashable {
    case openRegister(store: LoginStore)
    case openForgot
    
    case clickLogin(user: LoginCredentials)

    case click(field: LoginCredentialsField)
    case check(field: LoginCredentialsField, input: String)

    case cleanError

    func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: self))
    }

    static func == (lhs: LoginAction, rhs: LoginAction) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

