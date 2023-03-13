import Foundation
import Combine

enum RegisterationMutation: Mutation {
    case registrationCredentials((credentials: RegistrationCredentialsField, status: InputTextFieldStatus))

    case progressStatus(_ status: ProgressViewStatus)

    case setErrorMessage(_ error: Error?)

    case close
}

