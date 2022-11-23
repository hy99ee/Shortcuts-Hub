import Foundation

enum RegistrationAction: Action {
    case create(newUser: RegistrationCredentials)

    case mockAction
}

