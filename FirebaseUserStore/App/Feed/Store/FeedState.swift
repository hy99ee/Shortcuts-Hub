import SwiftUI
import Combine

struct FeedState: StateType {
    var loadItems: [LoaderItem] = []
    var items: [Item] = [] {
        didSet {
            showErrorView = false
        }
    }

    var showEmptyView = false
    var showErrorView = false

    var viewProgress = ProgressViewProvider()

    let processView: ProcessViewProvider

    init() {
        processView = ProcessViewProvider(viewProgress)
    }

    func reinit() -> Self {
        FeedState()
    }
}

extension FeedState {
    static var sortingByModified: (Item, Item) -> Bool = {
        $0.modifiedAt ?? $0.createdAt < $1.modifiedAt ?? $1.createdAt
    }

    func itemsWithFilter(_ filter: String) -> [Item] {
        items.filter { $0.title.lowercased().contains(filter.lowercased()) }
    }
}
