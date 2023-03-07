import SwiftUI
import Combine

struct LibraryState: StateType {
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

    var loginState: SessionState = .loading

    var searchFilter = ""

    var showEmptyView = false
    var showErrorView = false

    var viewProgress = ProgressViewProvider()
    var buttonProgress = ProgressViewProvider()

    let processView: ProcessViewProvider

    init() {
        processView = ProcessViewProvider(viewProgress, buttonProgress)
    }

    func reinit() -> Self {
        LibraryState()
    }
}

extension LibraryState {
    static var sortingByModified: (Item, Item) -> Bool = {
        $0.modifiedAt ?? $0.createdAt < $1.modifiedAt ?? $1.createdAt
    }
}
