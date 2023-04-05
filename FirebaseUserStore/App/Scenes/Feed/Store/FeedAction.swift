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

    case mockAction

    func hash(into hasher: inout Hasher) {
        switch self {
        case .initFeed:
            hasher.combine(-1)
        case .updateFeed:
            hasher.combine(0)
        case .click:
            hasher.combine(1)
        case .addSections:
            hasher.combine(2)
        case .search:
            hasher.combine(5)
        case .showAlert:
            hasher.combine(8)
        case .showFeedError:
            hasher.combine(7)
        case .mockAction:
            hasher.combine(10)
        case .changeSearchField:
            hasher.combine(11)
        }
    }

    static func == (lhs: FeedAction, rhs: FeedAction) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
