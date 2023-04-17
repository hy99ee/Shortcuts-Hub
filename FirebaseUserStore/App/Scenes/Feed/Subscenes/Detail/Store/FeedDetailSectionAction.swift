import Foundation

enum FeedDetailSectionAction: Action, Hashable {
    case initDetail
    case close

    func hash(into hasher: inout Hasher) {
        switch self {
        case .initDetail: hasher.combine(0)
        case .close: hasher.combine(1)
        }
    }

    static func == (lhs: FeedDetailSectionAction, rhs: FeedDetailSectionAction) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}


