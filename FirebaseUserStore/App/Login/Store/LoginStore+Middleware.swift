import Combine
import Foundation

typealias LoginStore = StateStore<LoginState, LoginAction, LoginMutation, LoginPackages>

extension LoginStore {
    static let middleware1: LoginStore.StoreMiddlewareRepository.Middleware = { state, action, packages in
        switch action {
        case .mockAction:
            return Fail(error: StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(
                action: LoginAction.mockAction,
                type: .excludeRedispatch
            )).eraseToAnyPublisher()
        default: break
        }
        return Just(action).setFailureType(to: StoreMiddlewareRepository.MiddlewareRedispatch.self).eraseToAnyPublisher()
        
    }
}
