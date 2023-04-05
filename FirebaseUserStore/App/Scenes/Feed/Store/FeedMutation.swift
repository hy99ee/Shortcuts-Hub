import Foundation
import Combine

enum FeedMutation: Mutation {
    case updateSectionsPreloaders(count: Int)
    case updateSections(_ sections: [IdsSection])
    case appendSections(_ sections: [IdsSection])

    case searchItems(_ items: [Item])
    case setSearchFilter(_ text: String)

    case fastUpdate

    case detail(section: IdsSection)

    case empty

    case errorAlert(error: Error)
    case errorFeed

    case progressViewStatus(status: ProgressViewStatus)
}
