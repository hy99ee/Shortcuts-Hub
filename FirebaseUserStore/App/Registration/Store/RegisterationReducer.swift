import Combine
import Foundation

let registerationReducer: ReducerType<RegisterationState, RegisterationMutation, NoneTransition> = { _state, mutation in
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
        state.progress.progressStatus = status
        
    case let .errorAlert(error):
        state.alert.error = error

    case .close:
        break
    }

    return Just(.state(state)).eraseToAnyPublisher()
}

