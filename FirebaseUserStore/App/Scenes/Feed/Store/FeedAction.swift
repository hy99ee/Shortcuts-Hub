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
        switch self {
        case .initFeed: hasher.combine(0)
        case .updateFeed: hasher.combine(1)
        case .click: hasher.combine(2)
        case .addSections: hasher.combine(3)
        case .search: hasher.combine(4)
        case .showAlert: hasher.combine(5)
        case .showFeedError: hasher.combine(6)
        case .changeSearchField: hasher.combine(7)
        }
    }

    static func == (lhs: FeedAction, rhs: FeedAction) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
