import Combine
import SwiftUI

typealias FeedDetailSectionStore = StateStore<FeedDetailSectionState, FeedDetailSectionAction, FeedDetailSectionMutation, FeedDetailSectionPackages, CloseTransition>

extension FeedDetailSectionStore {
    static let middlewareFetch: FeedDetailSectionStore.StoreMiddlewareRepository.Middleware = { state, action, packages in
        if action == .initDetail {
            return Fail(
                error: StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(
                    actions: [.updateWithSection(state.idsSection)]
                )
            ).eraseToAnyPublisher()
        }
        
        return Just(action)
            .setFailureType(to: StoreMiddlewareRepository.MiddlewareRedispatch.self)
            .eraseToAnyPublisher()
    }
}