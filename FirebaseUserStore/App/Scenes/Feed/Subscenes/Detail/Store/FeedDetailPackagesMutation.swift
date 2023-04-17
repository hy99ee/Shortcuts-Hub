import Foundation
import Combine

enum FeedDetailSectionMutation: Mutation {
    case fetchedSection(_ section: ItemsSection)
    case close
}

