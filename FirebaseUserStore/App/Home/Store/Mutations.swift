import Foundation

enum FeedMutation: Mutation {
    case errorAlert(error: Error)
    
    case startMutation
    case fetchItems(newItems: [Item])
    case newItem(item: Item)
}
