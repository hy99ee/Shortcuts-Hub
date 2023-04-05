import Combine
import SwiftUI

let feedReducer: ReducerType<FeedState, FeedMutation, FeedLink> = { _state, mutation in
    var state = _state

    switch mutation {
    case let .updateSectionsPreloaders(count):
        state.loadItems = []
        state.sections = []

        for index in 0..<count {
            state.loadItems!.append(LoaderItem(id: index))
        }

    case let .updateSections(sections):
        state.showEmptyView = sections.isEmpty
                              && state.searchFilter.isEmpty
                              && state.viewProgress == .stop
        state.loadItems = nil
        state.searchedItems = nil
        state.sections = sections

    case let .appendSections(sections):
        state.loadItems = nil
        state.searchedItems = nil
        state.sections += sections

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

    case let .detail(section):
        return Just(.coordinate(destination: .section(section))).eraseToAnyPublisher()

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
        state.sections = []
        state.showEmptyView = true
    }

    func errorData() {
        state.loadItems = []
        state.sections = []
        state.showErrorView = true
    }
}
