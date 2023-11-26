import Combine
import SwiftUDF

//MARK: Middleware
extension LibraryStore {
    static let middlewareAuthCheck: Middleware = { state, action, packages in
        guard action != .showAboutSheet && action != .openLogin else {
            if state.loginState == .loading {
                return Redispatch(
                    error: .redispatch(
                        actions: [.userLoginState(packages.sessionService.state), action],
                        type: .excludeRedispatch
                    )
                ).eraseToAnyPublisher()
            }

            return Just(action)
                .setFailureType(to: MiddlewareRedispatch.self)
                .eraseToAnyPublisher()
        }

        guard state.loginState == .loggedIn else {
            return Redispatch(
                error: .redispatch(
                    actions: [.userLoginState(.loggedIn), action],
                    type: .excludeRedispatch
                )
            ).eraseToAnyPublisher()
        }

        return Just(action)
            .setFailureType(to: MiddlewareRedispatch.self)
            .eraseToAnyPublisher()
    }

    static let middlewareUpdateCheck: Middleware = { state, action, packages in
        if action == .initLibrary,
           !packages.itemsService.isTimeTo(request: .initLibrary) {
            return Redispatch(
                error: .redispatch(
                    actions: .stopFlow()
                )
            ).eraseToAnyPublisher()
        }

        if action == .updateLibrary,
           !packages.itemsService.isTimeTo(request: .updateLibrary) {
            return Redispatch(
                error: .redispatch(
                    actions: .stopFlow()
                )
            ).eraseToAnyPublisher()
        }

        return Just(action)
            .setFailureType(to: MiddlewareRedispatch.self)
            .eraseToAnyPublisher()
    }

    static let middlewareInitClean: Middleware = { state, action, packages in
        if action == .initLibrary && state.searchFilter.isEmpty {
            return Redispatch(
                error: .redispatch(
                    actions: [
                        
                        action
                    ]
                )
            ).eraseToAnyPublisher()
        }
        return Just(action)
            .setFailureType(to: MiddlewareRedispatch.self)
            .eraseToAnyPublisher()
    }

    static let middlewareSearchCheck: Middleware = { state, action, packages in
        if action == .updateLibrary && !state.searchFilter.isEmpty {
            return Redispatch(
                error: .redispatch(
                    actions: [.search(text: state.searchFilter)]
                )
            ).eraseToAnyPublisher()
        }
        return Just(action)
            .setFailureType(to: MiddlewareRedispatch.self)
            .eraseToAnyPublisher()
    }

    static let middlewareDeletedNotOpen: Middleware = { state, action, packages in
        if case .click(let item) = action,
            state.itemsRemovingQueue.contains(item.id) {
            return Redispatch(
                error: .redispatch(
                    actions: .stopFlow()
                )
            ).eraseToAnyPublisher()
        }
        return Just(action)
            .setFailureType(to: MiddlewareRedispatch.self)
            .eraseToAnyPublisher()
    }
}
