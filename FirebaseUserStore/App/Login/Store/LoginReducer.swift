import Combine
import Foundation

let loginReducer: ReducerType<LoginState, LoginMutation, LoginLink> = { _state, mutation in
    var state = _state

    switch mutation {
    case let .showRegister(store):
        return Just(.coordinate(destination: .register)).eraseToAnyPublisher()

    case .showForgot:
        return Just(.coordinate(destination: .forgot)).eraseToAnyPublisher()

    case .login:
        return Just(.coordinate(destination: .close)).eraseToAnyPublisher()

    case let .progressLoginStatus(status):
        state.loginProgress = status
        state.processView = .define(with: state.loginProgress, state.registerProgress)

    case let .progressRegisterStatus(status):
        state.registerProgress = status
        state.processView = .define(with: state.loginProgress, state.registerProgress)
        
    case let .errorAlert(error):
        return Just(.coordinate(destination: .error(error))).eraseToAnyPublisher()

    case .errorWithRegister:
        break
    }

    return Just(.state(state)).eraseToAnyPublisher()
}

