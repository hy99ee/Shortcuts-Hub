import Combine
import SwiftUDF
import SwiftUI

let libraryReducer: ReducerType<LibraryState, LibraryMutation, LibraryLink> = { _state, mutation in
    var state = _state

    switch mutation {
    case let .updateItemsPreloaders(count):
        state.preloadItems = []
        for index in 0..<count {
            state.preloadItems!.append(LoaderItem(id: index))
        }
        configureFlags(by: .loaders)

    case let .updateItems(items):
        state.items = items
        configureFlags(by: .items)

        state.preloadItems = nil
        state.searchedItems = nil

    case let .appendItems(items):
        state.preloadItems = nil
        state.searchedItems = nil
        state.items += items
        configureFlags(by: .items)

    case .fastUpdate:
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
            configureFlags(by: .items)
        } else {
            configureFlags(by: .search)
        }


    case .openLogin:
        return Just(.coordinate(destination: .login)).eraseToAnyPublisher()

    case let .changeUserLoginState(status):
        state.loginState = status

    case let .detail(item):
        return Just(.coordinate(destination: .detail(item))).eraseToAnyPublisher()

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

    case let .errorAlert(error):
        return Just(.coordinate(destination: .error(error))).eraseToAnyPublisher()

    case .errorLibrary:
        state.preloadItems = []
        state.items = []

        configureFlags(by: .error)

    case let .showAbout(data):
        return Just(.coordinate(destination: .about(data))).eraseToAnyPublisher()

    case let .progressView(status):
        state.viewProgress = status
        state.processView = .define(with: state.viewProgress, state.buttonProgress)

    case let .progressItem(item, status):
        if status == .stop {
            state.itemsRemovingQueue.removeAll { $0 == item.id }
        } else {
            state.itemsRemovingQueue.append(item.id)
        }

    case let .progressButton(status):
        state.buttonProgress = status
        state.processView = .define(with: state.viewProgress, state.buttonProgress)

    case .hasLogout:
        break

    case .hasDeletedUser:
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
            state.isShowErrorView = state.preloadItems?.isEmpty
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
