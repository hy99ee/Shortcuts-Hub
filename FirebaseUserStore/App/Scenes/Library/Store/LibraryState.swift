import Combine
import SwiftUDF

struct LibraryState: StateType, ReinitableByNewSelf {
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

    var showEmptyView = false
    var showErrorView = false

    var viewProgress: ProgressViewStatus = .stop
    var buttonProgress: ProgressViewStatus = .stop
    var processView: ProcessViewStatus = .enable
}

extension LibraryState {
    static var sortingByModified: (Item, Item) -> Bool = {
        $0.modifiedAt ?? $0.createdAt < $1.modifiedAt ?? $1.createdAt
    }
}
