import Combine
import SwiftUDF
import SwiftUI

//typealias SavedState = CollectionState
struct SavedState: StateType, ReinitableByNewSelf {
    var items: [Item] = []
    var loadingItems: [LoaderItem]?
    var searchedItems: [Item]?

    var lastAdded: Item?
    var itemsRemovingQueue: [UUID] = []

    var loginState: SessionState = .loading

    var searchFilter = ""

    var isShowEmptySearchView: Bool?
    var isShowEmptyView: Bool?

    var isShowErrorView: Bool?

    var viewProgress: ProgressViewStatus = .stop
    var buttonProgress: ProgressViewStatus = .stop
    var processView: ProcessViewStatus = .enable
}

extension SavedState {
    static var sortingByModified: (Item, Item) -> Bool = {
        $0.modifiedAt ?? $0.createdAt < $1.modifiedAt ?? $1.createdAt
    }
}
