import Combine
import SwiftUDF
import SwiftUI

let savedReducer: ReducerType<SavedState, SavedMutation, SavedLink> = { _state, mutation in
    var state = _state

    switch mutation {
    case let .updateItemsPreloaders(count):
        state.loadingItems = []
        for index in 0..<count {
            state.loadingItems!.append(LoaderItem(id: index))
        }
        configureFlags(by: .loaders)

    case let .updateItems(items):
        state.items = items
        configureFlags(by: .items)

        state.loadingItems = nil
        state.searchedItems = nil

    case let .appendItems(items):
        state.loadingItems = nil
        state.searchedItems = nil
        state.items += items
        configureFlags(by: .items)

    case let .searchItems(items):
        if state.searchFilter.isEmpty {
            state.searchedItems = nil
            configureFlags(by: .items)
        } else {
            state.searchedItems = items
            configureFlags(by: .search)
        }

    case let .setSearchFilter(text):
        state.searchFilter = text

        if text.isEmpty {
            state.searchedItems = nil
        }

    case let .addItem(item):
        state.items.insert(item, at: 0)
        configureFlags(by: .items)

        if state.searchedItems != nil, item.tags.contains(state.searchFilter) {
            state.searchedItems!.insert(item, at: 0)
            configureFlags(by: .search)
        }

    case let .removeItem(item):
        state.items.removeAll { $0 == item }
        configureFlags(by: .items)

        if state.searchedItems != nil {
            state.searchedItems!.removeAll { $0 == item }
            configureFlags(by: .search)
        }

    case let .detail(item):
        return Just(.coordinate(destination: .detail(item))).eraseToAnyPublisher()

    case let .errorAlert(error):
        return Just(.coordinate(destination: .error(error))).eraseToAnyPublisher()

    case .errorSaved:
        state.loadingItems = []
        state.items = []

        configureFlags(by: .error)


    case let .progressView(status):
        state.viewProgress = status
        state.processView = .define(with: state.viewProgress, state.buttonProgress)

    case let .progressButton(status):
        state.buttonProgress = status
        state.processView = .define(with: state.viewProgress, state.buttonProgress)

    case .break:
        break
    }

    return Just(.state(state)).eraseToAnyPublisher()
    
    enum StateMutationTarget {
        case items
        case loaders
        case search
        case error
    }

    func configureFlags(by target: StateMutationTarget) {
        switch target {
        case .items:
            state.isShowEmptyView = state.items.isEmpty
            state.isShowErrorView = false
            state.isShowEmptySearchView = false
        case .loaders:
            state.isShowErrorView = state.loadingItems?.isEmpty
            state.isShowEmptyView = false
            state.isShowEmptySearchView = false
        case .search:
            state.isShowEmptySearchView = state.searchedItems?.isEmpty
            state.isShowEmptyView = false
            state.isShowErrorView = false
        case .error:
            state.isShowEmptySearchView = false
            state.isShowEmptyView = false
            state.isShowErrorView = true
        }
    }
}
