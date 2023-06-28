import Combine
import SwiftUDF

let loginReducer: ReducerType<LoginState, LoginMutation, LoginLink> = { _state, mutation in
    var state = _state

    switch mutation {
    case let .showRegister(store):
        return Just(.coordinate(destination: .register)).eraseToAnyPublisher()

    case .showForgot:
        return Just(.coordinate(destination: .forgot)).eraseToAnyPublisher()

    case .login:
        return Just(.coordinate(destination: .close)).eraseToAnyPublisher()

    case let .registrationCredentials(field):
        state.fieldsStatus.updateValue(field.status, forKey: field.credentials)
        if field.status == .valid && state.fieldsStatus.map({ $0.value.isStateValidForAccept }).filter({ !$0 }).isEmpty {
            state.singUpButtonValid = true
        } else {
            state.singUpButtonValid = false
        }

    case let .progressLoginStatus(status):
        state.viewProgress = status
        state.processView = .define(with: state.viewProgress, state.registerProgress, state.forgotProgress)

    case let .progressRegisterStatus(status):
        state.registerProgress = status
        state.processView = .define(with: state.viewProgress, state.registerProgress, state.forgotProgress)
        
    case let .setErrorMessage(error):
        state.loginErrorMessage = error?.localizedDescription ?? nil
    }

    return Just(.state(state)).eraseToAnyPublisher()
}

