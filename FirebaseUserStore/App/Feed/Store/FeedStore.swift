import Combine
import Foundation

typealias FeedStore = StateStore<FeedState, FeedDispatcher, FeedPackages>
typealias MockFeedStore = StateStore<FeedState, FeedDispatcher, FeedPackages>

extension FeedStore {
    static let middleware1: FeedStore.MiddlewareStore.Middleware = { state, action, _ in
        print("---> FeedStore.middleware1: { print state items before mutation\nitems: \(state.items) <---}")
        return Just(action).setFailureType(to: MiddlewareStore.MiddlewareRedispatch.self).eraseToAnyPublisher()
    }

    static let middleware2: FeedStore.MiddlewareStore.Middleware = { state, action, _ in
        print("---> FeedStore.middleware2: { print isMainThread: \(Thread.isMainThread) <---}")
        return Just(action).setFailureType(to: MiddlewareStore.MiddlewareRedispatch.self).eraseToAnyPublisher()
    }

    static let middleware3: FeedStore.MiddlewareStore.Middleware = { _, action, _ in
        print("---> FeedStore.middleware3 { .mockAction => .updateFeed } <---")
        switch action {
        case FeedAction.mockAction:
            return Fail(error: MiddlewareStore.MiddlewareRedispatch.redispatch(action: FeedAction.updateFeed)).eraseToAnyPublisher()
        default: return Just(action).setFailureType(to: MiddlewareStore.MiddlewareRedispatch.self).eraseToAnyPublisher()
        }
    }

    static let middleware4: FeedStore.MiddlewareStore.Middleware = { _, action, _ in
        print("---> FeedStore.middleware4: { .delay 3 seconds } <---")
        return Just(action).delay(for: .seconds(3), scheduler: DispatchQueue.main).setFailureType(to: MiddlewareStore.MiddlewareRedispatch.self).eraseToAnyPublisher()
    }
}
