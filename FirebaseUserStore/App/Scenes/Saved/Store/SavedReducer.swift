import Combine
import SwiftUI

let savedReducer: ReducerType<SavedState, SavedMutation, SavedLink> = { _state, mutation in
    var state = _state

    switch mutation {
    case let .updateItemsPreloaders(count):
        state.loadItems = []
        state.items = []

        for index in 0..<count {
            state.loadItems!.append(LoaderItem(id: index))
        }

    case let .fetchedItems(items):
        state.showEmptyView = items.isEmpty
                              && state.searchFilter.isEmpty
                              && state.viewProgress == .stop
        state.loadItems = nil
        state.searchedItems = nil
        state.items = items

    case let .fetchedNewItems(items):
        state.loadItems = nil
        state.searchedItems = nil
        state.items += items

    case .fastUpdate:
        break

    case let .searchItems(items):
        state.searchedItems = items

    case .cancelSearch:
        state.searchedItems = nil
        state.searchFilter = ""

    case let .setSearchFilter(text):
        state.searchFilter = text

    case .empty:
        emptyData()

    case let .detail(item):
        return Just(.coordinate(destination: .detail(item))).eraseToAnyPublisher()

    case let .errorAlert(error):
        return Just(.coordinate(destination: .error(error))).eraseToAnyPublisher()

    case .errorSaved:
        errorData()


    case let .progressView(status):
        state.viewProgress = status
        state.processView = .define(with: state.viewProgress, state.buttonProgress)

    case let .progressButton(status):
        state.buttonProgress = status
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
