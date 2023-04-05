import Foundation
import Combine

enum SavedMutation: Mutation {
    case updateItemsPreloaders(count: Int)
    case fetchedItems(newItems: [Item])
    case fetchedNewItems(_ items: [Item])
    case fastUpdate

    case searchItems(_ items: [Item])
    case setSearchFilter(_ text: String)

    case addItem(_ item: Item)
    case removeItem(_ item: Item)

    case detail(item: Item)

    case empty

    case errorAlert(error: Error)
    case errorSaved

    case progressButton(status: ProgressViewStatus)
    case progressView(status: ProgressViewStatus)
}