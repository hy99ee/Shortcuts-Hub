import Combine
import Foundation

var feedReducer: ReducerType<FeedState, FeedMutation> = { _state, mutation in
    var state = _state
    switch mutation {
    case let .fetchItems(items):
        state.items = items.sorted(by: FeedState.sortingByModified)

    case let .newItem(item):
        state.items.append(item)

    case let .removeItem(id):
        state.removedById(id)

    case let .errorAlert(error):
        state.alertProvider.error = error

    case let .showAbout(aboutData):
        state.aboutSheetProvider.sheetView = AboutView(aboutData: aboutData)
    }

    return Just(state).eraseToAnyPublisher()
}

