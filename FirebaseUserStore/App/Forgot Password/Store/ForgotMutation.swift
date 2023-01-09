import Foundation
import Combine

enum ForgotMutation: Mutation {
    case progressForgotStatus(_ status: ProgressViewStatus)

    case validEmailField

    case errorAlert(error: Error)
    case error

    case close
}

