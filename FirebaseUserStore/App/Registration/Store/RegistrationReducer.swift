import Combine
import Foundation

var registrationReducer: ReducerType<RegistrationState, RegistrationMutation> = { _state, mutation in
    var state = _state
    switch mutation {
    case .newUser:
        state.created = true

    case let .errorAlert(error):
        state.alertProvider.error = error

    case let .progressViewStatus(status):
        state.progressViewProvier.progressStatus = status
    }

    return Just(state).eraseToAnyPublisher()
}

