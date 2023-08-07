import Combine
import SwiftUDF
import SwiftUI

struct SavedState: StateType, ReinitableByNewSelf {
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

    var searchedItems: [Item]?
    var lastAdded: Item?

    var loginState: SessionState = .loading

    var searchFilter = ""

    var isShowEmptyView: Bool?
    var isShowErrorView = false

    var viewProgress: ProgressViewStatus = .stop
    var buttonProgress: ProgressViewStatus = .stop
    var processView: ProcessViewStatus = .enable
}

extension SavedState {
    static var sortingByModified: (Item, Item) -> Bool = {
        $0.modifiedAt ?? $0.createdAt < $1.modifiedAt ?? $1.createdAt
    }
}
