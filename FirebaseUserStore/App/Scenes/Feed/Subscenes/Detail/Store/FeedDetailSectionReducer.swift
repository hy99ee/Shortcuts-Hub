import Combine
import Foundation

let feedDetailSectionReducer: ReducerType<FeedDetailSectionState, FeedDetailSectionMutation, CloseTransition> = { _state, mutation in
    var state = _state
    switch mutation {
    case let .fetchedSection(section):
        state.itemsSection = section

    case .close:
        return Just(.coordinate(destination: .close)).eraseToAnyPublisher()
    }

    return Just(.state(state)).eraseToAnyPublisher()
}

