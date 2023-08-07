import Combine
import SwiftUDF

struct LibraryState: StateType, ReinitableByNewSelf {
    var loadItems: [LoaderItem]? {
        didSet {
            isShowErrorView = false
        }
    }
    var items: [Item] = [] {
        didSet {
            isShowErrorView = false
        }
    }

    var searchedItems: [Item]? {
        didSet {
            if searchedItems == nil {
                isShowEmptySearchView = nil
            } else {
                isShowEmptySearchView = searchedItems!.count < 1
            }
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
