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
        if action == .initSaved, !state.items.isEmpty {
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
    
}
