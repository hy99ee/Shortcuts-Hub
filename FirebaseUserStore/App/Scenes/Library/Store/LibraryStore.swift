import Foundation
import Combine
import SwiftUDF

typealias LibraryStore = StateStore<LibraryState, LibraryAction, LibraryMutation, LibraryPackages, LibraryLink>

extension LibraryStore: CollectionDelegate {
    var navigationTitle: String { "Library" }

    var items: [Item] {
        state.items
    }

    var preloadItems: [LoaderItem]? {
        state.preloadItems
    }

    var searchedItems: [Item]? {
        state.searchedItems
    }

    var viewProgress: ProgressViewStatus {
        state.viewProgress
    }

    var toolbarItems: [ToolbarCollectionItem] {
        [
            ToolbarCollectionItem(iconName: "person") { self.dispatch(.showAboutSheet) }
        ]
    }

    func update() {
        self.dispatch(.updateLibrary)
    }

    func search(_ text: String) {
        self.dispatch(.search(text: text))
    }

    func click(_ item: Item) {
        self.dispatch(.click(item))
    }

    func remove(_ item: Item) {
        self.dispatch(.removeFromLibrary(item: item))
    }

    func next() {
        self.dispatch(.next)
    }

    func isItemRemoving(_ item: Item) -> Bool {
        state.itemsRemovingQueue.contains(item.id)
    }
}

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

    static let middlewareAuthCheck: Middleware = { state, action, packages in
        if action == .showAboutSheet || action == .openLogin {
            if state.loginState == .loading {
                return Fail(
                    error: MiddlewareRedispatch.redispatch(
                        actions: [.userLoginState(packages.sessionService.state), action],
                        type: .excludeRedispatch
                    )
                ).eraseToAnyPublisher()
            }

            return Just(action).setFailureType(
                to: MiddlewareRedispatch.self
            ).eraseToAnyPublisher()
        }

        guard packages.sessionService.state == .loggedIn else {
            var actions: [LibraryAction] = [.userLoginState(.loggedOut)]
            if action != .initLibrary {
                actions.append(.openLogin)
            }

            return Fail(
                error: MiddlewareRedispatch.redispatch(
                    actions: actions,
                    type: .excludeRedispatch
                )
            ).eraseToAnyPublisher()
        }

        if state.loginState != .loggedIn {
            return Fail(
                error: MiddlewareRedispatch.redispatch(
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
        if action == .initLibrary, !state.items.isEmpty {
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

    static let middlewareSearchCheck: Middleware = { state, action, packages in
        if action == .updateLibrary && !state.searchFilter.isEmpty {
            return Fail(
                error: MiddlewareRedispatch.redispatch(
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
}
