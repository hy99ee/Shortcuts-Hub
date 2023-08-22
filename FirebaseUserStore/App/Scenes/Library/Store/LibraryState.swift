import Combine
import SwiftUDF

struct LibraryState: StateType, ReinitableByNewSelf {
    var items: [Item] = [] {
        didSet {
            isShowEmptyView = items.isEmpty

            isShowErrorView = false
            isShowEmptySearchView = false
        }
    }

    var preloadItems: [LoaderItem]? {
        didSet {
            isShowErrorView = false
            isShowEmptyView = false
            isShowEmptySearchView = false
        }
    }

    var searchedItems: [Item]? {
        didSet {
            isShowEmptySearchView = searchedItems?.isEmpty ?? false

            isShowEmptyView = false
            isShowErrorView = false
        }
    }
    var lastAdded: Item?
    var removingItem: Item?

    var loginState: SessionState = .loading

    var searchFilter = ""

    var isShowEmptySearchView: Bool?
    var isShowEmptyView: Bool?

    var isShowErrorView = false

    var viewProgress: ProgressViewStatus = .stop
    var buttonProgress: ProgressViewStatus = .stop
    var processView: ProcessViewStatus = .enable
}

extension LibraryState {
    static var sortingByModified: (Item, Item) -> Bool = {
        $0.modifiedAt ?? $0.createdAt < $1.modifiedAt ?? $1.createdAt
    }
}
