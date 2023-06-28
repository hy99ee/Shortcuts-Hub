import Combine
import SwiftUDF

typealias SavedStore = StateStore<SavedState, SavedAction, SavedMutation, SavedPackages, SavedLink>

extension SavedStore {
    func updatedSessionStatus(_ state: SessionState) {
        switch state {
        case .loggedIn:
            self.reinit()
            self.dispatch(.updateSaved)

        case .loggedOut:
            self.reinit()

        case .loading:
            break
        }
    }

    static let middlewareUpdateCheck: Middleware = { state, action, packages in
        if (action == .initSaved || action == .initLocalSaved),
            !state.items.isEmpty {
            return Fail(
                error: MiddlewareRedispatch.redispatch(
                    actions: []
                )
            ).eraseToAnyPublisher()
        }

        return Just(action)
            .setFailureType(to: MiddlewareRedispatch.self)
            .eraseToAnyPublisher()
    }

    static let middlewareLocalItems: Middleware = { state, action, packages in
        guard packages.itemsService?.savedIds == nil else {
            return Just(action)
                .setFailureType(to: MiddlewareRedispatch.self)
                .eraseToAnyPublisher()
        }
        
        switch action {
        case .initSaved:
            return Fail(
                error: MiddlewareRedispatch.redispatch(
                    actions: [.initLocalSaved]
                )
            ).eraseToAnyPublisher()

        case .updateSaved:
            return Fail(
                error: MiddlewareRedispatch.redispatch(
                    actions: [.updateLocalSaved]
                )
            ).eraseToAnyPublisher()

        case let .search(text: text):
            return Fail(
                error: MiddlewareRedispatch.redispatch(
                    actions: [.search(text: text)]
                )
            ).eraseToAnyPublisher()

        default:
            return Just(action)
                .setFailureType(to: MiddlewareRedispatch.self)
                .eraseToAnyPublisher()
        }
    }
}
