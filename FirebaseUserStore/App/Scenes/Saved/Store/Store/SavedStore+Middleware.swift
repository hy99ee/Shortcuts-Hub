import Combine

//MARK: Middleware
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
                error: .redispatch(
                    actions: .stopFlow()
                )
            ).eraseToAnyPublisher()
        }

        // Is need update when view onRefresh
        if (action == .updateSaved || action == .updateLocalSaved),
           !packages.itemsService.isTimeTo(request: .updateSaved) {
            return Fail(
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
            return Fail(
                error: .redispatch(
                    actions: [.initLocalSaved]
                )
            ).eraseToAnyPublisher()

        case .updateSaved:
            return Fail(
                error: .redispatch(
                    actions: [.updateLocalSaved]
                )
            ).eraseToAnyPublisher()

        case let .search(text: text):
            return Fail(
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
            return Fail(
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
            return Fail(
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
