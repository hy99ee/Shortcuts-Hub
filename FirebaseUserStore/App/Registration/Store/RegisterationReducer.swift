import Combine
import Foundation

let registerationReducer: ReducerType<RegisterationState, RegisterationMutation, NoneTransition> = { _state, mutation in
    var state = _state
    switch mutation {
    case .registrationCredentials(_):
        break
        
    case let .progressStatus(status):
        state.progress.progressStatus = status
        
    case let .errorAlert(error):
        state.alert.error = error

    case .close:
        break
    }

    return Just(.state(state)).eraseToAnyPublisher()
}

