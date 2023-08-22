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

    case let .updateItems(items):
        state.preloadItems = nil
        state.searchedItems = nil
        state.items = items

    case let .appendItems(items):
        state.preloadItems = nil
        state.searchedItems = nil
        state.items += items

    case .fastUpdate:
        break

    case let .searchItems(items):
        state.searchedItems = !state.searchFilter.isEmpty ? items : nil

    case let .setSearchFilter(text):
        state.searchFilter = text

        if text.isEmpty { state.searchedItems = nil }

    case .openLogin:
        return Just(.coordinate(destination: .login)).eraseToAnyPublisher()

    case let .changeUserLoginState(status):
        state.loginState = status

    case let .detail(item):
        return Just(.coordinate(destination: .detail(item))).eraseToAnyPublisher()

    case let .addItem(item):
        state.items.insert(item, at: 0)

        if state.searchedItems != nil, item.tags.contains(state.searchFilter) {
            state.searchedItems!.insert(item, at: 0)
        }

    case let .removeItem(item):
        state.items.removeAll { $0 == item }

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

    case let .progressItem(item, status):
        state.removingItem = status == .stop ? nil : item

    case let .progressButton(status):
        state.buttonProgress = status
        state.processView = .define(with: state.viewProgress, state.buttonProgress)

    case .hasLogout:
        break

    case .hasDeletedUser:
        break
    }

    return Just(.state(state)).eraseToAnyPublisher()

    func errorData() {
        state.preloadItems = []
        state.items = []
        state.isShowErrorView = true
    }
}
