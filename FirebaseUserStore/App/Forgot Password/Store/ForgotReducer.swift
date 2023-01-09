import Combine
import Foundation

let forgotReducer: ReducerType<ForgotState, ForgotMutation, GlobalLink> = { _state, mutation in
    var state = _state
    switch mutation {
    case let .progressForgotStatus(status):
        state.forgotProgress.progressStatus = status
    
    case .validEmailField:
        state.isValidEmailField = true

    case let .errorAlert(error):
        state.alert.error = error

    case .error:
        state.isValidEmailField = false

    case .close:
        break
    }

    return Just((state, nil)).eraseToAnyPublisher()
}

