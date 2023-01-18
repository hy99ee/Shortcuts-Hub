import Foundation
import Combine

enum RegisterationMutation: Mutation {
    case registrationCredentials(_ registration: RegistrationCredentials)
    
    case progressStatus(_ status: ProgressViewStatus)

    case errorAlert(error: Error)

    case close
}

