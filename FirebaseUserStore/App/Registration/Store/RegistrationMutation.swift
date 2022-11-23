import Foundation
import Combine

enum RegistrationMutation: Mutation {
    case newUser(user: RegistrationCredentials)
    case errorAlert(error: Error)
    case progressViewStatus(status: ProgressViewStatus)
}

