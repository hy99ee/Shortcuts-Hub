import Combine
import Foundation

typealias FeedStore = StateStore<FeedState, FeedAction, FeedMutation, FeedPackages, FeedLink>

extension FeedStore {
    static let middlewareFeedLogger: FeedStore.StoreMiddlewareRepository.Middleware = { state, action, packages in
        print("===State=== \(state)")
        print("===Action=== \(action)")
        return Just(action).setFailureType(to: StoreMiddlewareRepository.MiddlewareRedispatch.self).eraseToAnyPublisher()
    }

    static let middlewareUpdateCheck: FeedStore.StoreMiddlewareRepository.Middleware = { state, action, packages in
        if action == .initFeed, !state.sections.isEmpty {
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
