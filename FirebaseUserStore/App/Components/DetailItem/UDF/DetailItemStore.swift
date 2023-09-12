import Combine
import SwiftUDF
import SwiftUI

typealias DetailItemStore = StateStore<DetailItemState, DetailItemAction, DetailItemMutation, DetailItemPackages, ErrorTransition>

extension DetailItemStore {
    enum Operation {
        case saved
        case unsaved
    }
}

extension DetailItemStore {
    static let middlewareOperation: Middleware = { state, action, packages in
        if action == .addToSaved {
            return Fail(
                error: .redispatch(
                    actions: [.itemByOperation(item: state.item, operation: .saved)]
                )
            ).eraseToAnyPublisher()
        } else if action == .removeFromSaved {
            return Fail(
                error: .redispatch(
                    actions: [.itemByOperation(item: state.item, operation: .unsaved)]
                )
            ).eraseToAnyPublisher()
        }
        
        return Just(action)
            .setFailureType(to: MiddlewareRedispatch.self)
            .eraseToAnyPublisher()
    }
}
