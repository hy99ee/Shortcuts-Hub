import Combine
import SwiftUI

let feedReducer: ReducerType<FeedState, FeedMutation, FeedLink> = { _state, mutation in
    var state = _state

    switch mutation {
    case let .updateItemsPreloaders(count):
        state.loadItems = []
        state.items = []

        for index in 0..<count {
            state.loadItems!.append(LoaderItem(id: index))
        }

    case let .updateItems(items):
        state.showEmptyView = items.isEmpty
                              && state.searchFilter.isEmpty
                              && state.viewProgress == .stop
        state.loadItems = nil
        state.searchedItems = nil
        state.items = items

    case let .appendItems(items):
        state.loadItems = nil
        state.searchedItems = nil
        state.items += items

    case .fastUpdate:
        break

    case let .searchItems(items):
        state.searchedItems = !state.searchFilter.isEmpty ? items : nil

    case let .setSearchFilter(text):
        state.searchFilter = text

        if text.isEmpty {
            state.searchedItems = nil
        }
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
