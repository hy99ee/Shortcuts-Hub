import Combine
import SwiftUI

let feedReducer: ReducerType<FeedState, FeedMutation, FeedLink> = { _state, mutation in
    var state = _state

    switch mutation {
    case let .fetchItemsPreloaders(count):
        state.showEmptyView = count == 0
        state.loadItems = []
        state.items = []

        for index in 0..<count {
            state.loadItems.append(LoaderItem(id: index))
        }

    case let .fetchItems(items):
        let items = items.sorted(by: FeedState.sortingByModified)
        state.showEmptyView = items.isEmpty
        state.loadItems = []
        state.items = items

    case .empty:
        emptyData()

    case let .detail(item):
        return Just(.coordinate(destination: .detail(item))).eraseToAnyPublisher()

    case let .addItems(items):
        state.items.append(contentsOf: items)

    case let .errorAlert(error):
        return Just(.coordinate(destination: .error(error))).eraseToAnyPublisher()

    case .errorFeed:
        errorData()

    case let .progressViewStatus(status):
        state.viewProgress = status
        state.processView = .define(with: state.viewProgress, state.buttonProgress)
    }

    return Just(.state(state)).eraseToAnyPublisher()
    
    func emptyData() {
        state.loadItems = []
        state.items = []
        state.showEmptyView = true
    }

    func errorData() {
        state.loadItems = []
        state.items = []
        state.showErrorView = true
    }
}
