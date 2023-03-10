import Foundation
import Combine

enum LibraryMutation: Mutation {
    case updateItemsPreloaders(count: Int)
    case fetchedItems(newItems: [Item])
    case fetchedNewItems(_ items: [Item])

    case searchItems(_ items: [Item])
    case cancelSearch
    case setSearchFilter(_ text: String)

    case fastUpdate

    case detail(item: Item)

    case newItem(item: Item, lastDate: Date?)
    case addItems(items: [Item])
    case removeItem(id: UUID)
    case empty

    case changeUserLoginState(_ state: SessionState)
    case openLogin

    case hasLogout
    case hasDeletedUser

    case errorAlert(error: Error)
    case errorLibrary

    case showAbout(_ data: AboutViewData)
    case progressButton(status: ProgressViewStatus)
    case progressView(status: ProgressViewStatus)
}
