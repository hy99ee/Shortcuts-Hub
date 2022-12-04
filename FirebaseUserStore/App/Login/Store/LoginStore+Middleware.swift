import Combine
import Foundation

typealias LoginStore = StateStore<LoginState, LoginDispatcher, LoginPackages>

extension LoginStore {
    static let middleware1: LoginStore.MiddlewareStore.Middleware = { state, action, packages in
        switch action {
        case .mockAction:
            return Fail(error:
                    MiddlewareStore.MiddlewareRedispatch.redispatch(
                        action: LoginAction.mockAction,
                        type: .excludeRedispatch
                    )
            ).eraseToAnyPublisher()
        default: break
        }
        return Just(action).setFailureType(to: MiddlewareStore.MiddlewareRedispatch.self).eraseToAnyPublisher()
        
    }
}
