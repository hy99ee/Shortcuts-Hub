import Foundation

enum FeedAction: Action {
    case updateFeed
    case addItems(items: [Item])
    case addItem
    case removeItem(id: UUID)
    case search(query: String)

    case showAboutSheet
    case showAlert(error: Error)

    case logout

    case mockAction
}
