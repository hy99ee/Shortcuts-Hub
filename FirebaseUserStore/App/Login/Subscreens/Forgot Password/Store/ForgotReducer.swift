import Combine
import Foundation

let forgotReducer: ReducerType<ForgotState, ForgotMutation, CloseTransition> = { _state, mutation in
    var state = _state
    switch mutation {
    case let .progressForgotStatus(status):
        state.progress = status
    
    case let .emailFieldStatus(status):
        if case let .unvalidWithMessage(message) = status {
            state.emailErrorMessage = message
        } else {
            state.emailErrorMessage = nil
        }

    case .close:
        return Just(.coordinate(destination: .close)).eraseToAnyPublisher()
    }

    return Just(.state(state)).eraseToAnyPublisher()
}

