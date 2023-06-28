import SwiftUDF

enum FeedDetailSectionAction: Action, Hashable {
    case initDetail
    case updateFeedWithSection(_ section: IdsSection)
    case replaceItem(_ item: Item, index: Int)
    case open(item: Item)

    case close

    func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: self))
    }

    static func == (lhs: FeedDetailSectionAction, rhs: FeedDetailSectionAction) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}


