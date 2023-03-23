import SwiftUI
import Combine

struct FeedState: StateType {
    var loadItems: [LoaderItem]? {
        didSet {
            showErrorView = false
        }
    }
    var items: [Item] = [] {
        didSet {
            showErrorView = false
        }
    }

    var searchedItems: [Item]?
    var searchFilter = ""

    var showEmptyView = false
    var showErrorView = false

    var viewProgress: ProgressViewStatus = .stop
    var buttonProgress: ProgressViewStatus = .stop
    var processView: ProcessViewStatus = .enable
}

extension FeedState {
    static var sortingByModified: (Item, Item) -> Bool = {
        $0.modifiedAt ?? $0.createdAt > $1.modifiedAt ?? $1.createdAt
    }

    func itemsWithFilter(_ filter: String) -> [Item] {
        items.filter { $0.title.lowercased().contains(filter.lowercased()) }
    }
}
