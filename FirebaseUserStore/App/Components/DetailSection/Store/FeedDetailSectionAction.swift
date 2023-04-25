import Foundation

enum FeedDetailSectionAction: Action, Hashable {
    case initDetail
    case updateFeedWithSection(_ section: IdsSection)

    case open(item: Item)
    case addToSaved(item: Item)
    case removeFromSaved(item: Item)

    case close

    func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: self))
    }

    static func == (lhs: FeedDetailSectionAction, rhs: FeedDetailSectionAction) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}


