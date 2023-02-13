import Combine
import Foundation

typealias LibraryStore = StateStore<LibraryState, LibraryAction, LibraryMutation, LibraryPackages, LibraryLink>

extension LibraryStore {
    static let middlewareLocalSearch: LibraryStore.StoreMiddlewareRepository.Middleware = { state, action, packages in
        switch action {
        case let LibraryAction.search(text, _):
            if text.isEmpty { return Fail(error: StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(actions: [.updateLibrary], type: .repeatRedispatch)).eraseToAnyPublisher()}
            if state.items.isEmpty { return Just(action).setFailureType(to: StoreMiddlewareRepository.MiddlewareRedispatch.self).eraseToAnyPublisher() }

            let filteredItems = state.itemsWithFilter(text)
            let filteredItemsIds = Set(filteredItems.map { $0.id })
            return Fail(error: StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(actions:[.clean, .addItems(items: filteredItems), .search(text: text, local: filteredItemsIds)], type: .excludeRedispatch)).eraseToAnyPublisher()

        default: return Just(action).setFailureType(to: StoreMiddlewareRepository.MiddlewareRedispatch.self).eraseToAnyPublisher()
        }
    }

    static let middlewareAuthCheck: LibraryStore.StoreMiddlewareRepository.Middleware = { state, action, packages in
        if action == .showAboutSheet || action == .userHasLogged || action == .openLogin {
            if !state.isLogin && packages.sessionService.state == .loggedIn {
                return Fail(error: StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(actions: [.userHasLogged, action], type: .excludeRedispatch)).eraseToAnyPublisher()
            }

            return Just(action).setFailureType(to: StoreMiddlewareRepository.MiddlewareRedispatch.self).eraseToAnyPublisher()
        }

        guard packages.sessionService.state == .loggedIn else {
            return Fail(error: StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(actions: [.openLogin], type: .excludeRedispatch)).eraseToAnyPublisher()
        }

        if !state.isLogin {
            return Fail(error: StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(actions: [.userHasLogged, action], type: .excludeRedispatch)).eraseToAnyPublisher()
        }

        return Just(action).setFailureType(to: StoreMiddlewareRepository.MiddlewareRedispatch.self).eraseToAnyPublisher()
    }
}
