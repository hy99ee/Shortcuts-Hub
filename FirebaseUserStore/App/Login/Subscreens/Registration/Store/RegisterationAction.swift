import Foundation

enum RegisterationAction: Action, Hashable {
    case click(field: RegistrationCredentialsField)
    case check(field: RegistrationCredentialsField, input: String)
    case clickRegisteration(user: RegistrationCredentials)

    func hash(into hasher: inout Hasher) {
        switch self {
        case .click:
            hasher.combine(0)
        case .check:
            hasher.combine(1)
        case .clickRegisteration:
            hasher.combine(2)
        }
    }

    static func == (lhs: RegisterationAction, rhs: RegisterationAction) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

