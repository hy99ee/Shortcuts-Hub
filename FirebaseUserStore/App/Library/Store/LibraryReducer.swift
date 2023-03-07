import Combine
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

    case let .fetchedItems(items):
        state.showEmptyView = items.isEmpty
                              && state.loadItems != nil
                              && state.searchFilter.isEmpty
                              && state.viewProgress.progressStatus == .stop
        state.loadItems = nil
        state.searchedItems = nil
        state.items = items.sorted(by: LibraryState.sortingByModified)

    case let .fetchedNewItems(items):
//        let items = items.sorted(by: LibraryState.sortingByModified)
        state.loadItems = nil
        state.searchedItems = nil
        state.items += items.sorted(by: LibraryState.sortingByModified)

    case .fastUpdate:
        break

    case let .searchItems(items):
        state.searchedItems = items.sorted(by: LibraryState.sortingByModified)

    case .cancelSearch:
        state.searchedItems = nil
        state.searchFilter = ""

    case let .setSearchFilter(text):
        state.searchFilter = text

    case .empty:
        emptyData()
    
    case .openLogin:
        return Just(.coordinate(destination: .login)).eraseToAnyPublisher()

    case let .changeUserLoginState(status):
        state.loginState = status

    case let .detail(item):
        return Just(.coordinate(destination: .detail(item))).eraseToAnyPublisher()

    case let .addItems(items):
        state.items.append(contentsOf: items)

    case let .newItem(item):
        if state.searchedItems != nil {
            state.searchedItems!.append(item)
        }
        state.items.append(item)

        state.showEmptyView = false

    case let .removeItem(id):
        state.items.removeAll { $0.id == id }
        if state.items.isEmpty { state.showEmptyView = true }

    case let .errorAlert(error):
        return Just(.coordinate(destination: .error(error))).eraseToAnyPublisher()

    case .errorLibrary:
        errorData()

    case let .showAbout(data):
        return Just(.coordinate(destination: .about(data))).eraseToAnyPublisher()

    case let .progressViewStatus(status):
        state.viewProgress.progressStatus = status

    case let .progressButtonStatus(status):
        state.buttonProgress.progressStatus = status

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
