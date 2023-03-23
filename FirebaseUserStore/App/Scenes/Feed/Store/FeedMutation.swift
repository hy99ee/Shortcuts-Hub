import Foundation
import Combine

enum FeedMutation: Mutation {
    case updateItemsPreloaders(count: Int)
    case updateItems(_ newItems: [Item])
    case appendItems(_ items: [Item])

    case searchItems(_ items: [Item])
    case setSearchFilter(_ text: String)

    case fastUpdate

    case detail(item: Item)

    case addItems(items: [Item])

    case empty

    case errorAlert(error: Error)
    case errorFeed

    case progressViewStatus(status: ProgressViewStatus)
}
