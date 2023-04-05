import Combine
import Foundation

typealias LibraryStore = StateStore<LibraryState, LibraryAction, LibraryMutation, LibraryPackages, LibraryLink>

extension LibraryStore {
    func updatedSessionStatus(_ state: SessionState) {
        switch state {
        case .loggedIn:
            self.reinit()
            self.dispatch(.updateLibrary)

        case .loggedOut:
            self.reinit()

        case .loading:
            break
        }
    }

    static let middlewareAuthCheck: LibraryStore.StoreMiddlewareRepository.Middleware = { state, action, packages in
        if action == .showAboutSheet || action == .openLogin {
            if state.loginState == .loading {
                return Fail(
                    error: StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(
                        actions: [.userLoginState(packages.sessionService.state), action],
                        type: .excludeRedispatch
                    )
                ).eraseToAnyPublisher()
            }

            return Just(action).setFailureType(
                to: StoreMiddlewareRepository.MiddlewareRedispatch.self
            ).eraseToAnyPublisher()
        }

        guard packages.sessionService.state == .loggedIn else {
            return Fail(
                error: StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(
                    actions: [.userLoginState(.loggedOut), .openLogin],
                    type: .excludeRedispatch
                )
            ).eraseToAnyPublisher()
        }

        if state.loginState != .loggedIn {
            return Fail(
                error: StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(
                    actions: [.userLoginState(.loggedIn), action],
                    type: .excludeRedispatch
                )
            ).eraseToAnyPublisher()
        }

        return Just(action)
            .setFailureType(to: StoreMiddlewareRepository.MiddlewareRedispatch.self)
            .eraseToAnyPublisher()
    }

    static let middlewareUpdateCheck: LibraryStore.StoreMiddlewareRepository.Middleware = { state, action, packages in
        if action == .initLibrary, !state.items.isEmpty {
            return Fail(
                error: StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(
                    actions: []
                )
            ).eraseToAnyPublisher()
        }

        return Just(action)
            .setFailureType(to: StoreMiddlewareRepository.MiddlewareRedispatch.self)
            .eraseToAnyPublisher()
    }

    static let middlewareSearchCheck: LibraryStore.StoreMiddlewareRepository.Middleware = { state, action, packages in
        if action == .updateLibrary && !state.searchFilter.isEmpty {
            return Fail(
                error: StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(
                    actions: [.search(text: state.searchFilter)]
                )
            ).eraseToAnyPublisher()
        }
        return Just(action)
            .setFailureType(to: StoreMiddlewareRepository.MiddlewareRedispatch.self)
            .eraseToAnyPublisher()
    }
}
