import Foundation

enum FeedAction: Action {
    case updateFeed
    case addItem
    case removeItem(id: UUID)
    case search(query: String)

    case showAboutSheet
    case showAlert(error: Error)

    case logout

    case mockAction
}
