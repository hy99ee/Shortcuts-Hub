import Foundation
import Combine

enum LibraryMutation: Mutation {
    case fetchItemsPreloaders(count: Int)
    case fetchItems(newItems: [Item])

    case refreshLibraryWithLocalItems

    case clean


    case detail(item: Item)

    case newItem(item: Item)
    case addItems(items: [Item])
    case removeItem(id: UUID)
    case empty

    case userHasLogged
    case logout
    case openLogin

    case errorAlert(error: Error)
    case errorLibrary

    case showAbout(data: AboutViewData)
    case progressButtonStatus(status: ProgressViewStatus)
    case progressViewStatus(status: ProgressViewStatus)
}
