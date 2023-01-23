import Foundation
import Combine

enum RegisterationMutation: Mutation {
    case registrationCredentials((credentials: RegistrationCredentialsField, status: InputTextFieldStatus))

    case progressStatus(_ status: ProgressViewStatus)

    case errorAlert(error: Error)

    case close
}

