import Foundation

enum LoginAction: Action, Hashable {
    case openRegister(store: LoginStore)
    case openForgot
    
    case clickLogin(user: LoginCredentials)

    case click(field: LoginCredentialsField)
    case check(field: LoginCredentialsField, input: String)

    case cleanError

    func hash(into hasher: inout Hasher) {
        switch self {
        case .openRegister:
            hasher.combine(0)
        case .openForgot:
            hasher.combine(1)
        case .clickLogin:
            hasher.combine(2)
        case .click:
            hasher.combine(3)
        case .check:
            hasher.combine(4)
        case .cleanError:
            hasher.combine(5)
        }
    }

    static func == (lhs: LoginAction, rhs: LoginAction) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

