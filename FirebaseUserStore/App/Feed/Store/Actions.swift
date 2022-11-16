import Foundation

enum FeedAction: Action {
    case updateFeed
    case addItem
    case removeItem(id: UUID)

    case showAboutSheet(serviceData: SessionServiceSlice)
}
