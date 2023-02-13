import Foundation
import Combine

enum FeedMutation: Mutation {
    case fetchItemsPreloaders(count: Int)
    case fetchItems(newItems: [Item])
    case clean

    case detail(item: Item)

    case addItems(items: [Item])

    case empty

    case errorAlert(error: Error)
    case errorFeed

    case progressViewStatus(status: ProgressViewStatus)
}
