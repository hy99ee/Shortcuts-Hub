import Combine
import SwiftUDF

//MARK: Middleware
extension SavedStore {
    static let middlewareUpdateCheck: Middleware = { state, action, packages in
        // Is need update when view onAppear
        if (action == .initSaved || action == .initLocalSaved),
           !packages.itemsService.isTimeTo(request: .initSaved) {
            return Redispatch(
                error: .redispatch(
                    actions: .stopFlow()
                )
            ).eraseToAnyPublisher()
        }

        // Is need update when view onRefresh
        if (action == .updateSaved || action == .updateLocalSaved),
           !packages.itemsService.isTimeTo(request: .updateSaved) {
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

    static let middlewareLocalItems: Middleware = { state, action, packages in
        guard packages.itemsService?.savedIds == nil else {
            return Just(action)
                .setFailureType(to: MiddlewareRedispatch.self)
                .eraseToAnyPublisher()
        }

        switch action {
        case .initSaved:
            return Redispatch(
                error: .redispatch(
                    actions: [.initLocalSaved]
                )
            ).eraseToAnyPublisher()

        case .updateSaved:
            return Redispatch(
                error: .redispatch(
                    actions: [.updateLocalSaved]
                )
            ).eraseToAnyPublisher()

        case let .search(text: text):
            return Redispatch(
                error: .redispatch(
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
