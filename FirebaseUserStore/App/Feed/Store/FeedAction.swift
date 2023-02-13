import Foundation

enum FeedAction: Action, Hashable {
    case updateFeed

    case click(_ item: Item)

    case addItems(items: [Item])
    case search(text: String, local: Set<UUID> = Set())
    case clean

    case showAlert(error: Error)
    case showFeedError

    case mockAction

    func hash(into hasher: inout Hasher) {
        switch self {
        case .updateFeed:
            hasher.combine(0)
        case .click:
            hasher.combine(1)
        case .addItems:
            hasher.combine(2)
        case .search:
            hasher.combine(5)
        case .clean:
            hasher.combine(6)
        case .showAlert:
            hasher.combine(8)
        case .showFeedError:
            hasher.combine(7)
        case .mockAction:
            hasher.combine(10)
        }
    }

    static func == (lhs: FeedAction, rhs: FeedAction) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
