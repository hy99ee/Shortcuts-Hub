import Combine
import SwiftUDF
import SwiftUI

let libraryReducer: ReducerType<LibraryState, LibraryMutation, LibraryLink> = { _state, mutation in
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
    
    case .openLogin:
        return Just(.coordinate(destination: .login)).eraseToAnyPublisher()

    case let .changeUserLoginState(status):
        state.loginState = status

    case let .detail(item):
        return Just(.coordinate(destination: .detail(item))).eraseToAnyPublisher()

    case let .addItem(item):
        state.items.insert(item, at: 0)
        state.showEmptyView = false

        if state.searchedItems != nil, item.tags.contains(state.searchFilter) {
            state.searchedItems!.insert(item, at: 0)
        }

    case let .removeItem(item):
        state.items.removeAll { $0 == item }
        if state.items.isEmpty { state.showEmptyView = true }

        if state.searchedItems != nil {
            state.searchedItems!.removeAll { $0 == item }
        }

    case let .errorAlert(error):
        return Just(.coordinate(destination: .error(error))).eraseToAnyPublisher()

    case .errorLibrary:
        errorData()

    case let .showAbout(data):
        return Just(.coordinate(destination: .about(data))).eraseToAnyPublisher()

    case let .progressView(status):
        state.viewProgress = status
        state.processView = .define(with: state.viewProgress, state.buttonProgress)

    case let .progressButton(status):
        state.buttonProgress = status
        state.processView = .define(with: state.viewProgress, state.buttonProgress)

    case .hasLogout:
        break

    case .hasDeletedUser:
        break
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
