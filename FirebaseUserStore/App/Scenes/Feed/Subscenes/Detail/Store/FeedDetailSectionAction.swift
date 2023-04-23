import Foundation

enum FeedDetailSectionAction: Action, Hashable {
    case initDetail
    case updateWithSection(_ section: IdsSection)
    case openItem(_ item: Item)
    case close

    func hash(into hasher: inout Hasher) {
        switch self {
        case .initDetail: hasher.combine(0)
        case .updateWithSection: hasher.combine(1)
        case .openItem: hasher.combine(2)
        case .close: hasher.combine(3)
        }
    }

    static func == (lhs: FeedDetailSectionAction, rhs: FeedDetailSectionAction) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}


