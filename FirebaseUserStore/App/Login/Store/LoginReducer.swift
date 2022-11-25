import Combine
import Foundation

var loginReducer: ReducerType<LoginState, LoginMutation> = { _state, mutation in
    var state = _state
    switch mutation {
    case let .showRegister(store):
        state.registerProvider.sheetView = RegisterView(store: store)

    case let .showForgot(store):
        state.forgotProvider.sheetView = ForgotPasswordView(store: store)

    case .closeForgot:
        state.forgotProvider.sheetView = nil

    case .login(_):
        break

    case .newUser:
        break
        
    case let .errorAlert(error):
        state.alertProvider.error = error
        
    case let .progressViewStatus(status):
        state.progressViewProvier.progressStatus = status

    }

    return Just(state).eraseToAnyPublisher()
}

