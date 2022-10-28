import Foundation

enum FeedMutation: Mutation {
    case fetchItems(newItems: [Item])
    case newItem(item: Item)
    case removeItem(id: UUID)

    case errorAlert(error: Error)
}
