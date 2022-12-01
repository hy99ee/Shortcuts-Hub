import Combine
import Foundation

typealias FeedStore = StateStore<FeedState, FeedDispatcher, FeedPackages>
typealias MockFeedStore = StateStore<FeedState, FeedDispatcher, FeedPackages>

extension FeedStore {
    static let middleware1: FeedStore.MiddlewareStore.Middleware = { state, action, _ in
        print("---> FeedStore.middleware1: { print state items before mutation\nitems: \(state.items) } <---")
        return Just(action).setFailureType(to: MiddlewareStore.MiddlewareRedispatch.self).eraseToAnyPublisher()
    }

    static let middleware2: FeedStore.MiddlewareStore.Middleware = { state, action, _ in
        print("---> FeedStore.middleware2: { print isMainThread: \(Thread.isMainThread) } <---")
        return Just(action).setFailureType(to: MiddlewareStore.MiddlewareRedispatch.self).eraseToAnyPublisher()
    }

    static let middleware3: FeedStore.MiddlewareStore.Middleware = { _, action, _ in
        print("---> FeedStore.middleware3 { .mockAction => .updateFeed } <---")
        switch action {
        case FeedAction.mockAction:
            return Fail(error:
                            MiddlewareStore.MiddlewareRedispatch.redispatch(
                                action: FeedAction.updateFeed,
                                type: .repeatRedispatch
                            )
            ).eraseToAnyPublisher()
        default: return Just(action).setFailureType(to: MiddlewareStore.MiddlewareRedispatch.self).eraseToAnyPublisher()
        }
    }

    static let middleware4: FeedStore.MiddlewareStore.Middleware = { _, action, _ in
        print("---> FeedStore.middleware4: { .delay 3 seconds } <---")
        return Just(action).delay(for: .seconds(3), scheduler: DispatchQueue.main).setFailureType(to: MiddlewareStore.MiddlewareRedispatch.self).eraseToAnyPublisher()
    }

    static let middleware5: FeedStore.MiddlewareStore.Middleware = { _, action, packages in
        print("---> FeedStore.middleware5: { checking user data } <---")
        if
            packages.sessionService.userDetails == nil ||
            packages.itemsService.userId == nil {
            return Fail(error:
                            MiddlewareStore.MiddlewareRedispatch.redispatch(
                                action: FeedAction.logout,
                                type: .excludeRedispatch
                            )
            ).eraseToAnyPublisher()
        }
        return Just(action).setFailureType(to: MiddlewareStore.MiddlewareRedispatch.self).eraseToAnyPublisher()
    }

    static let middleware6: FeedStore.MiddlewareStore.Middleware = { _, action, packages in
        print("---> FeedStore.middleware5: { checking session state } <---")
        if packages.sessionService.state == .loggedOut {
            return Fail(error:
                            MiddlewareStore.MiddlewareRedispatch.redispatch(
                                action: FeedAction.logout,
                                type: .excludeRedispatch
                            )
            ).eraseToAnyPublisher()
        }
        return Just(action).setFailureType(to: MiddlewareStore.MiddlewareRedispatch.self).eraseToAnyPublisher()
    }

    static let middleware7: FeedStore.MiddlewareStore.Middleware = { state, action, packages in
        print("---> FeedStore.middleware5: { checking fullness of items } <---")
        if state.items == [] {
            return Fail(error:
                            MiddlewareStore.MiddlewareRedispatch.redispatch(
                                action: FeedAction.showAlert(error: ItemsServiceError.unknownError),
                                type: .excludeRedispatch
                            )
            ).eraseToAnyPublisher()
        }
        return Just(action).setFailureType(to: MiddlewareStore.MiddlewareRedispatch.self).eraseToAnyPublisher()
    }
}
