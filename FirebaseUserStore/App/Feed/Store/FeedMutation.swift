import Foundation
import Combine

enum FeedMutation: Mutation {
    case fetchItems(newItems: [Item])
    case newItem(item: Item)
    case removeItem(id: UUID)

    case logout

    case errorAlert(error: Error)
    case showAbout(data: AboutViewData)
    case progressButtonStatus(status: ProgressViewStatus)
    case progressViewStatus(status: ProgressViewStatus)
}
