import Combine
import SwiftUDF

typealias FeedStore = StateStore<FeedState, FeedAction, FeedMutation, FeedPackages, FeedLink>

extension FeedStore {
    static let middlewareFeedLogger: Middleware = { state, action, packages in
        print("===State=== \(state)")
        print("===Action=== \(action)")
        return Just(action).setFailureType(to: MiddlewareRedispatch.self).eraseToAnyPublisher()
    }

    static let middlewareUpdateCheck: Middleware = { state, action, packages in
        if action == .initFeed, !state.sections.isEmpty {
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
