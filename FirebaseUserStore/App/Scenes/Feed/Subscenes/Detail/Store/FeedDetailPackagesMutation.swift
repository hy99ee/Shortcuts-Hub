import Foundation
import Combine

enum FeedDetailSectionMutation: Mutation {
    case fetchedSection(_ items: [Item])
    case progressViewStatus(status: ProgressViewStatus)

    case close
}

