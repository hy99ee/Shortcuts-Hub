import Foundation

enum FeedAction: Action {
    case updateFeed
    case addItems(items: [Item])
    case addItem
    case removeItem(id: UUID)
    case search(text: String, local: Set<UUID> = Set())
    case clean

    case showAboutSheet
    case showAlert(error: Error)

    case logout

    case mockAction
}
