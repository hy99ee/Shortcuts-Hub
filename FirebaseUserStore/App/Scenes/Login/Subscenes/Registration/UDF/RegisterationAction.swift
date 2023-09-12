import SwiftUDF

enum RegisterationAction: Action, Hashable {
    case click(field: RegistrationCredentialsField)
    case check(field: RegistrationCredentialsField, input: String)
    case clickRegisteration(user: RegistrationCredentials)
    case cleanError

    func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: self))
    }

    static func == (lhs: RegisterationAction, rhs: RegisterationAction) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}


