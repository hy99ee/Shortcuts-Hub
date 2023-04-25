import Combine
import Foundation

let feedDetailItemReducer: ReducerType<DetailItemState, DetailItemMutation, ErrorTransition> = { _state, mutation in
    var state = _state
    switch mutation {
        
    case let .progressViewStatus(status):
        state.viewProgress = status
        state.processView = .define(with: state.viewProgress)
        
    case let .itemsSavedStatusChanged(operation):
        var _item = state.item
        let isSaved = operation == .saved
        _item.isSaved = isSaved
//        state.isSaved = DetailItemState.IsSaved(isSaved)
        state.item = _item
        
        
    case let .error(operation, error):
        return Just(.coordinate(destination: .error(error: error))).eraseToAnyPublisher()

    case .break:
        break
    }

    return Just(.state(state)).eraseToAnyPublisher()
}

