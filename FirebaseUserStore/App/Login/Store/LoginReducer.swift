import Combine
import Foundation

let loginReducer: ReducerType<LoginState, LoginMutation> = { _state, mutation in
    var state = _state
    switch mutation {
    case let .showRegister(store):
        state.registerSheet.initialize(with: store)

    case let .showForgot(store):
        state.forgotSheet.initialize(with: store)

    case .closeForgot:
        state.forgotSheet.deinitialize()

    case .login:
        break

    case .create:
        break

    case let .progressLoginStatus(status):
        state.loginProgress.progressStatus = status

    case let .progressRegisterStatus(status):
        state.registerProgress.progressStatus = status

    case let .progressForgotStatus(status):
        state.forgotProgress.progressStatus = status
        
    case let .errorAlert(error):
        state.alert.error = error

    case .errorWithRegister:
        break

    case .errorWithForgot:
        state.forgotSheet.isValidEmailField = false
    }

    return Just(state).eraseToAnyPublisher()
}

