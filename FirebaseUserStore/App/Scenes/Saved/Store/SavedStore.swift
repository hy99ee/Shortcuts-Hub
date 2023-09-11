import Combine
import SwiftUDF

class SavedStore: StateStore<SavedState, SavedAction, SavedMutation, SavedPackages, SavedLink> { }

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
        // Is need update when view onAppear
        if (action == .initSaved || action == .initLocalSaved),
           !packages.itemsService.isTimeTo(request: .initSaved) {
            return Fail(
                error: MiddlewareRedispatch.redispatch(
                    actions: .stopFlow()
                )
            ).eraseToAnyPublisher()
        }

        // Is need update when view onRefresh
        if (action == .updateSaved || action == .updateLocalSaved),
           !packages.itemsService.isTimeTo(request: .updateSaved) {
            return Fail(
                error: MiddlewareRedispatch.redispatch(
                    actions: .stopFlow()
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

    static let middlewareSearchCheck: Middleware = { state, action, packages in
        if (action == .updateSaved || action == .updateLocalSaved)
            && !state.searchFilter.isEmpty {
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
                    actions: .stopFlow()
                )
            ).eraseToAnyPublisher()
        }
        return Just(action)
            .setFailureType(to: MiddlewareRedispatch.self)
            .eraseToAnyPublisher()
    }
}

// MARK: Collection delegate
extension SavedStore: CollectionDelegate {
    var navigationTitle: String { "Saved" }

    var items: [Item] {
        state.items
    }

    var loadingItems: [LoaderItem]? {
        state.loadingItems
    }

    var searchedItems: [Item]? {
        state.searchedItems
    }

    var viewProgress: ProgressViewStatus {
        state.viewProgress
    }

    func update() {
        self.dispatch(.updateSaved)
    }

    func search(_ text: String) {
        self.dispatch(.search(text: text))
    }

    func click(_ item: Item) {
        self.dispatch(.click(item))
    }

    func remove(_ item: Item) {
        self.dispatch(.removeFromSaved(item: item))
    }

    func next() {
        self.dispatch(.next)
    }

    func isItemRemoving(_ item: Item) -> Bool {
        state.itemsRemovingQueue.contains(item.id)
    }
}
