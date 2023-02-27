import Combine
import Foundation

typealias LibraryStore = StateStore<LibraryState, LibraryAction, LibraryMutation, LibraryPackages, LibraryLink>

extension LibraryStore {
    static let middlewareLocalSearch: LibraryStore.StoreMiddlewareRepository.Middleware = { state, action, packages in
        switch action {
        case let LibraryAction.search(text, _):
            if text.isEmpty {
                return Fail(
                    error: StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(
                        actions: [.updateLibrary]
                    )
                ).eraseToAnyPublisher()
            }

            if state.items.isEmpty {
                return Just(action).setFailureType(
                    to: StoreMiddlewareRepository.MiddlewareRedispatch.self
                ).eraseToAnyPublisher()
            }

            let filteredItems = state.itemsWithFilter(text)
            let filteredItemsIds = Set(filteredItems.map { $0.id })

            return Fail(
                error: StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(
                    actions:[.clean, .addItems(items: filteredItems), .search(text: text, local: filteredItemsIds)],
                    type: .excludeRedispatch
                )
            ).eraseToAnyPublisher()

        default: return Just(action).setFailureType(
            to: StoreMiddlewareRepository.MiddlewareRedispatch.self)
        .eraseToAnyPublisher()
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
