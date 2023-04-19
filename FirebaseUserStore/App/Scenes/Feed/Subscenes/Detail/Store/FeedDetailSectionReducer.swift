import Combine
import Foundation

let feedDetailSectionReducer: ReducerType<FeedDetailSectionState, FeedDetailSectionMutation, CloseTransition> = { _state, mutation in
    var state = _state
    switch mutation {
    case .fetchedSection:
//        state.itemsSection = section
        break

    case let .progressViewStatus(status):
        state.viewProgress = status
        state.processView = .define(with: state.viewProgress)

    case .close:
        return Just(.coordinate(destination: .close)).eraseToAnyPublisher()
    }

    return Just(.state(state)).eraseToAnyPublisher()
}

