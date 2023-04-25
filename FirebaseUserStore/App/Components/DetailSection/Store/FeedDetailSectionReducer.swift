import Combine
import Foundation

let feedDetailSectionReducer: ReducerType<FeedDetailSectionState, FeedDetailSectionMutation, FeedDetailLink> = { _state, mutation in
    var state = _state
    switch mutation {
    case let .fetchedSection(items):
        state.itemsFromSection = items

    case let .progressViewStatus(status):
        state.viewProgress = status
        state.processView = .define(with: state.viewProgress)

    case let .replaceItemInSection(item, index):
        state.itemsFromSection[index] = item

    case let .openItemFromSection(item):
        return Just(.coordinate(destination: .open(item))).eraseToAnyPublisher()

    case .close:
        return Just(.coordinate(destination: .close)).eraseToAnyPublisher()
    }

    return Just(.state(state)).eraseToAnyPublisher()
}

