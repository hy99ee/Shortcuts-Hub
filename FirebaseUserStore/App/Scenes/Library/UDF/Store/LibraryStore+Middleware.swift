import Combine

//MARK: Middleware
extension LibraryStore {
    static let middlewareAuthCheck: Middleware = { state, action, packages in
        if action == .showAboutSheet || action == .openLogin {
            if state.loginState == .loading {
                return Fail(
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

        guard packages.sessionService.state == .loggedIn else {
            var actions: [LibraryAction] = [.userLoginState(.loggedOut)]
            if action != .initLibrary {
                actions.append(.openLogin)
            }

            return Fail(
                error: .redispatch(
                    actions: actions,
                    type: .excludeRedispatch
                )
            ).eraseToAnyPublisher()
        }

        if state.loginState != .loggedIn {
            return Fail(
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
            return Fail(
                error: .redispatch(
                    actions: .stopFlow()
                )
            ).eraseToAnyPublisher()
        }

        if action == .updateLibrary,
           !packages.itemsService.isTimeTo(request: .updateLibrary) {
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

    static let middlewareSearchCheck: Middleware = { state, action, packages in
        if action == .updateLibrary && !state.searchFilter.isEmpty {
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
}
