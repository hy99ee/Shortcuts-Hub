import Combine
import Foundation

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

    static let middlewareUpdateCheck: SavedStore.StoreMiddlewareRepository.Middleware = { state, action, packages in
        if (action == .initSaved || action == .initLocalSaved),
            !state.items.isEmpty {
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

    static let middlewareLocalItems: SavedStore.StoreMiddlewareRepository.Middleware = { state, action, packages in
        guard packages.itemsService?.user == nil else {
            return Just(action)
                .setFailureType(to: StoreMiddlewareRepository.MiddlewareRedispatch.self)
                .eraseToAnyPublisher()
        }
        
        switch action {
        case .initSaved:
            return Fail(
                error: StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(
                    actions: [.initLocalSaved]
                )
            ).eraseToAnyPublisher()

        case .updateSaved:
            return Fail(
                error: StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(
                    actions: [.updateLocalSaved]
                )
            ).eraseToAnyPublisher()

        case .search(text: let text):
            return Fail(
                error: StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(
                    actions: [.search(text: text)]
                )
            ).eraseToAnyPublisher()

        default:
            return Just(action)
                .setFailureType(to: StoreMiddlewareRepository.MiddlewareRedispatch.self)
                .eraseToAnyPublisher()
        }
    }
}
