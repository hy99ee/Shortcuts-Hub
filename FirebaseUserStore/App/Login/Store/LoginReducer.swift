import Combine
import Foundation

let loginReducer: ReducerType<LoginState, LoginMutation, LoginLink> = { _state, mutation in
    var state = _state
    var link: LoginLink?

    switch mutation {
    case let .showRegister(store):
        return Just(.coordinate(destination: .register)).eraseToAnyPublisher()

    case .showForgot:
        return Just(.coordinate(destination: .forgot)).eraseToAnyPublisher()

    case .login:
        break

    case .create:
        break

    case let .progressLoginStatus(status):
        state.loginProgress.progressStatus = status

    case let .progressRegisterStatus(status):
        state.registerProgress.progressStatus = status
        
    case let .errorAlert(error):
        return Just(.coordinate(destination: .error(error))).eraseToAnyPublisher()

    case .errorWithRegister:
        break
    }

    return Just(.state(state)).eraseToAnyPublisher()
}

