import Foundation
import Combine

enum ForgotMutation: Mutation {
    case progressForgotStatus(_ status: ProgressViewStatus)
    case emailFieldStatus(_ status: InputTextFieldStatus)
    case close
}

