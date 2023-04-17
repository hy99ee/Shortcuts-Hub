import Combine
import Foundation

let registerationReducer: ReducerType<RegisterationState, RegisterationMutation, CloseTransition> = { _state, mutation in
    var state = _state
    switch mutation {
    case let .registrationCredentials(field):
        state.fieldsStatus.updateValue(field.status, forKey: field.credentials)
        if field.status == .valid && state.fieldsStatus.map({ $0.value.isStateValidForAccept }).filter({ !$0 }).isEmpty {
            state.singUpButtonValid = true
        } else {
            state.singUpButtonValid = false
        }

    case let .progressStatus(status):
        state.progress = status
        
    case let .setErrorMessage(error):
        state.registrationErrorMessage = error?.localizedDescription ?? nil

    case .close:
        return Just(.coordinate(destination: .close)).eraseToAnyPublisher()
    }

    return Just(.state(state)).eraseToAnyPublisher()
}

