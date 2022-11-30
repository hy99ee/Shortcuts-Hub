import Combine
import Foundation

var loginReducer: ReducerType<LoginState, LoginMutation> = { _state, mutation in
    var state = _state
    switch mutation {
    case let .showRegister(store):
        state.registerSheet.sheetView = RegisterView(store: store)

    case let .showForgot(store):
        state.forgotSheet.sheetView = ForgotPasswordView(store: store)

    case .closeForgot:
        state.forgotSheet.sheetView = nil

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
    }

    return Just(state).eraseToAnyPublisher()
}

