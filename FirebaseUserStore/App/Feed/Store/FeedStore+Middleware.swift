import Combine
import Foundation

typealias FeedStore = StateStore<FeedState, FeedAction, FeedMutation, FeedPackages>

extension FeedStore {
    static let middlewareLocalSearch: FeedStore.StoreMiddlewareRepository.Middleware = { state, action, packages in
        print("---> FeedStore.middlewareLocalSearch { Emit two actions } <---")
        switch action {
        case let FeedAction.search(text, _):
            if text.isEmpty { return Fail(error: StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(actions: [.updateFeed], type: .repeatRedispatch)).eraseToAnyPublisher()}
            if state.items.isEmpty { return Just(action).setFailureType(to: StoreMiddlewareRepository.MiddlewareRedispatch.self).eraseToAnyPublisher() }
            
            let filteredItems = state.itemsWithFilter(text)
            let filteredItemsIds = Set(filteredItems.map { $0.id })
            return Fail(error: StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(actions:[.clean, .addItems(items: filteredItems), .search(text: text, local: filteredItemsIds)], type: .excludeRedispatch)).eraseToAnyPublisher()

        default: return Just(action).setFailureType(to: StoreMiddlewareRepository.MiddlewareRedispatch.self).eraseToAnyPublisher()
        }
    }
}
