import Combine
import SwiftUDF
import SwiftUI

typealias FeedDetailSectionStore = StateStore<FeedDetailSectionState, FeedDetailSectionAction, FeedDetailSectionMutation, FeedDetailSectionPackages, FeedDetailLink>

extension FeedDetailSectionStore {
    static let middlewareFetch: Middleware = { state, action, packages in
        if action == .initDetail {
            return Fail(
                error: .redispatch(
                    actions: [.updateFeedWithSection(state.idsSection)]
                )
            ).eraseToAnyPublisher()
        }
        
        return Just(action)
            .setFailureType(to: MiddlewareRedispatch.self)
            .eraseToAnyPublisher()
    }
}
