import Foundation

enum FeedAction: Action, Hashable {
    case initFeed
    case updateFeed

    case click(_ section: IdsSection)

    case addSections(_ sections: [IdsSection])

    case search(text: String)
    case changeSearchField(_ newText: String)

    case showAlert(error: Error)
    case showFeedError

    func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: self))
    }

    static func == (lhs: FeedAction, rhs: FeedAction) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
