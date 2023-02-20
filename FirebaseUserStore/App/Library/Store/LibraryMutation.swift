import Foundation
import Combine

enum LibraryMutation: Mutation {
    case fetchItemsPreloaders(count: Int)
    case fetchItems(newItems: [Item])

    case fastUpdate

    case setSearchFilter(_ text: String)

    case clean


    case detail(item: Item)

    case newItem(item: Item)
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
    case progressButtonStatus(status: ProgressViewStatus)
    case progressViewStatus(status: ProgressViewStatus)
}
