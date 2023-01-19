import Foundation

enum RegisterationAction: Action {
    case click(field: RegistrationCredentialsField)
    case check(field: RegistrationCredentialsField, input: String)
    case clickRegisteration(user: RegistrationCredentials)
}

