import Combine
import Foundation

typealias FeedStore = StateStore<FeedState, FeedAction, FeedMutation, FeedPackages, GlobalLink>

extension FeedStore {
    static let middlewareLocalSearch: FeedStore.StoreMiddlewareRepository.Middleware = { state, action, packages in
        print("---> FeedStore.middlewareLocalSearch { Local search } <---")
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

    static var count = 0
    static let middlewareUserValidation: FeedStore.StoreMiddlewareRepository.Middleware = { state, action, packages in
        print("---> FeedStore.middlewareLocalSearch { User validation } <---")
        guard count == 3, packages.itemsService.userId != nil else {
            count += 1
            return Fail(error: StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(actions: [.showFeedError], type: .excludeRedispatch)).eraseToAnyPublisher()
        }
        return Just(action).setFailureType(to: StoreMiddlewareRepository.MiddlewareRedispatch.self).eraseToAnyPublisher()
    }
}
