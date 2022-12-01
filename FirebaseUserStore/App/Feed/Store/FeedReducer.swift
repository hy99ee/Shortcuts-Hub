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

