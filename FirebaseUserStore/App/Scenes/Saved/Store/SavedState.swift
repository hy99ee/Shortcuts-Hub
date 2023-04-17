import SwiftUI
import Combine

struct SavedState: StateType, ReinitableByNewSelf {
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
    var lastAdded: Item?

    var loginState: SessionState = .loading

    var searchFilter = ""

    var showEmptyView: Bool?
    var showErrorView: Bool?

    var viewProgress: ProgressViewStatus = .stop
    var buttonProgress: ProgressViewStatus = .stop
    var processView: ProcessViewStatus = .enable
}

extension SavedState {
    static var sortingByModified: (Item, Item) -> Bool = {
        $0.modifiedAt ?? $0.createdAt < $1.modifiedAt ?? $1.createdAt
    }
}
