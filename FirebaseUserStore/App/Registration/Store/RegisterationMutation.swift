import Foundation
import Combine

enum RegisterationMutation: Mutation {
    case registrationCredentials((credentials: RegistrationCredentialsField, status: RegistrationFieldStatus))
    
    case progressStatus(_ status: ProgressViewStatus)

    case errorAlert(error: Error)

    case close
}

