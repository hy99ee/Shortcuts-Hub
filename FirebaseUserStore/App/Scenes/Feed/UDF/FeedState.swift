import Combine
import SwiftUDF
import SwiftUI

struct FeedState: StateType, ReinitableByNewSelf {
    var loadItems: [LoaderItem]? {
        didSet {
            isShowErrorView = false
        }
    }
    var sections: [IdsSection] = [] {
        didSet {
            isShowErrorView = false
        }
    }

    var searchedItems: [Item]?
    var searchFilter = ""

    var isShowEmptyView = false
    var isShowErrorView = false

    var viewProgress: ProgressViewStatus = .stop
    var buttonProgress: ProgressViewStatus = .stop
    var processView: ProcessViewStatus = .enable
}

extension FeedState {
    static var sortingByModified: (Item, Item) -> Bool = {
        $0.modifiedAt ?? $0.createdAt > $1.modifiedAt ?? $1.createdAt
    }

    func itemsWithFilter(_ filter: String) -> [IdsSection] {
        sections.filter { $0.title.lowercased().contains(filter.lowercased()) }
    }
}
