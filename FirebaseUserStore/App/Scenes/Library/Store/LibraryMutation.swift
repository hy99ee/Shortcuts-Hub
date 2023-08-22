import Combine
import SwiftUDF

enum LibraryMutation: Mutation {
    case updateItemsPreloaders(count: Int)
    case updateItems(_ newItems: [Item])
    case appendItems(_ items: [Item])

    case searchItems(_ items: [Item])
    case setSearchFilter(_ text: String)

    case fastUpdate

    case detail(item: Item)

    case addItem(_ item: Item)
    case removeItem(_ item: Item)

    case changeUserLoginState(_ state: SessionState)
    case openLogin

    case hasLogout
    case hasDeletedUser

    case errorAlert(error: Error)
    case errorLibrary

    case showAbout(_ data: AboutViewData)
    case progressButton(status: ProgressViewStatus)
    case progressItem(item: Item, status: ProgressViewStatus)
    case progressView(status: ProgressViewStatus)
}
