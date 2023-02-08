import Combine
import Foundation

typealias LibraryStore = StateStore<LibraryState, LibraryAction, LibraryMutation, LibraryPackages, LibraryLink>

extension LibraryStore {
    static let middlewareLocalSearch: LibraryStore.StoreMiddlewareRepository.Middleware = { state, action, packages in
        switch action {
        case let LibraryAction.search(text, _):
            if text.isEmpty { return Fail(error: StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(actions: [.updateLibrary], type: .repeatRedispatch)).eraseToAnyPublisher()}
            if state.items.isEmpty { return Just(action).setFailureType(to: StoreMiddlewareRepository.MiddlewareRedispatch.self).eraseToAnyPublisher() }

            let filteredItems = state.itemsWithFilter(text)
            let filteredItemsIds = Set(filteredItems.map { $0.id })
            return Fail(error: StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(actions:[.clean, .addItems(items: filteredItems), .search(text: text, local: filteredItemsIds)], type: .excludeRedispatch)).eraseToAnyPublisher()

        default: return Just(action).setFailureType(to: StoreMiddlewareRepository.MiddlewareRedispatch.self).eraseToAnyPublisher()
        }
    }
}
