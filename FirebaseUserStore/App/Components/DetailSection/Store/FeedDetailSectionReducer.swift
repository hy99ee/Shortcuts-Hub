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

    case let .openItemFromSection(item):
        return Just(.coordinate(destination: .open(item))).eraseToAnyPublisher()

    case let .itemSaved(item):
        state.itemsFromSection = state.itemsFromSection.map {
            if $0 == item {
                var savedItem = $0
                savedItem.isSaved = true
                return savedItem
            } else {
                return $0
            }
        }

    case let .itemUnsaved(item):
        state.itemsFromSection = state.itemsFromSection.map {
            if $0 == item {
                var unsavedItem = $0
                unsavedItem.isSaved = false
                return unsavedItem
            } else {
                return $0
            }
        }

    case .close:
        return Just(.coordinate(destination: .close)).eraseToAnyPublisher()
    }

    return Just(.state(state)).eraseToAnyPublisher()
}

