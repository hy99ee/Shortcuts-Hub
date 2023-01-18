import Foundation

enum RegisterationAction: Action {
    case check(field: RegistrationCredentialsField)
    case clickRegisteration(user: RegistrationCredentials)
}

