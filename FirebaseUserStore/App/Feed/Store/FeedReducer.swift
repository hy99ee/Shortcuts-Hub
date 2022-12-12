import Combine
import SwiftUI

let feedReducer: ReducerType<FeedState, FeedMutation> = { _state, mutation in
    var state = _state
    switch mutation {
    case let .fetchItemsPreloaders(count):
        state.itemsPreloadersCount = count
        state.items = []

    case let .fetchItems(items):
        state.itemsPreloadersCount = 0
        state.items = items.sorted(by: FeedState.sortingByModified)

    case .empty:
        state.showEmptyView = true

    case let .newItem(item):
        state.items.append(item)
        state.showEmptyView = state.items.isEmpty

    case let .removeItem(id):
        state.items.removeAll { $0.id == id }
        state.showEmptyView = state.items.isEmpty

    case let .errorAlert(error):
        state.alert.error = error

    case let .showAbout(data):
        state.aboutSheetProvider.sheetView = AboutView(aboutData: data)

    case let .progressViewStatus(status):
        state.viewProgress.progressStatus = status

    case let .progressButtonStatus(status):
        state.buttonProgress.progressStatus = status

    case .logout:
        break
    }

    return Just(state).eraseToAnyPublisher()
}
