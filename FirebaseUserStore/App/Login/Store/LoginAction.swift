import Foundation

enum LoginAction: Action, Hashable {
    case openRegister(store: LoginStore)
    case openForgot
    
    case clickLogin(user: LoginCredentials)

    func hash(into hasher: inout Hasher) {
        switch self {
        case .openRegister:
            hasher.combine(0)
        case .openForgot:
            hasher.combine(1)
        case .clickLogin:
            hasher.combine(2)
        }
    }

    static func == (lhs: LoginAction, rhs: LoginAction) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

