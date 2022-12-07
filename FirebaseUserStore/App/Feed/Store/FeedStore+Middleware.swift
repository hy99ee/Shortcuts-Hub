import Combine
import Foundation

typealias FeedStore = StateStore<FeedState, FeedAction, FeedMutation, FeedPackages>

extension FeedStore {
    static let middlewareItemsCheck: FeedStore.StoreMiddlewareRepository.Middleware = { state, action, _ in
        print("---> FeedStore.middleware1: { print state items before mutation\nitems: \(state.items) } <---")
        return Just(action).setFailureType(to: StoreMiddlewareRepository.MiddlewareRedispatch.self).eraseToAnyPublisher()
    }

    static let middleware1: FeedStore.StoreMiddlewareRepository.Middleware = { state, action, _ in
        print("---> FeedStore.middleware1: { print state items before mutation\nitems: \(state.items) } <---")
        return Just(action).setFailureType(to: StoreMiddlewareRepository.MiddlewareRedispatch.self).eraseToAnyPublisher()
    }

    static let middleware2: FeedStore.StoreMiddlewareRepository.Middleware = { state, action, _ in
        print("---> FeedStore.middleware2: { print isMainThread: \(Thread.isMainThread) } <---")
        return Just(action).setFailureType(to: StoreMiddlewareRepository.MiddlewareRedispatch.self).eraseToAnyPublisher()
    }

    static let middleware3: FeedStore.StoreMiddlewareRepository.Middleware = { _, action, _ in
        print("---> FeedStore.middleware3 { .mockAction => .updateFeed } <---")
        switch action {
        case FeedAction.mockAction:
            return Fail(error:
                            StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(
                                action: FeedAction.updateFeed,
                                type: .repeatRedispatch
                            )
            ).eraseToAnyPublisher()
        default: return Just(action).setFailureType(to: StoreMiddlewareRepository.MiddlewareRedispatch.self).eraseToAnyPublisher()
        }
    }

    static let middleware5: FeedStore.StoreMiddlewareRepository.Middleware = { _, action, packages in
        print("---> FeedStore.middleware5: { checking user data } <---")
        if
            packages.sessionService.userDetails == nil ||
            packages.itemsService.userId == nil {
            return Fail(error:
                            StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(
                                action: FeedAction.logout,
                                type: .excludeRedispatch
                            )
            ).eraseToAnyPublisher()
        }
        return Just(action).setFailureType(to: StoreMiddlewareRepository.MiddlewareRedispatch.self).eraseToAnyPublisher()
    }

    static let middleware6: FeedStore.StoreMiddlewareRepository.Middleware = { _, action, packages in
        print("---> FeedStore.middleware6: { checking session state } <---")
        if packages.sessionService.state == .loggedOut {
            return Fail(error:
                            StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(
                                action: FeedAction.logout,
                                type: .excludeRedispatch
                            )
            ).eraseToAnyPublisher()
        }
        return Just(action).setFailureType(to: StoreMiddlewareRepository.MiddlewareRedispatch.self).eraseToAnyPublisher()
    }

    static let middleware7: FeedStore.StoreMiddlewareRepository.Middleware = { state, action, packages in
        print("---> FeedStore.middleware7: { checking fullness of items } <---")
        if state.items == [] {
            return Fail(error:
                            StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(
                                action: action,
                                type: .excludeRedispatch
                            )
            ).eraseToAnyPublisher()
        }
        return Just(action).setFailureType(to: StoreMiddlewareRepository.MiddlewareRedispatch.self).eraseToAnyPublisher()
    }
}
