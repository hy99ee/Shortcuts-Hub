import SwiftUI
import Combine

struct FeedState: StateType {
    var itemsPreloadersCount = 0 {
        didSet {
            loadItems = Array(repeating: LoaderItem(), count: itemsPreloadersCount)
        }
    }

    var loadItems: [LoaderItem] = []
    var items: [Item] = []
    var showEmptyView = false
    
    var alert = AlertProvider()
    var aboutSheetProvider = SheetProvider<AboutView>(presentationDetent: [.height(200), .medium])

    var viewProgress = ProgressViewProvider()
    var buttonProgress = ProgressViewProvider()

    let processViewProgress: ProcessViewProvider

    init() {
        processViewProgress = ProcessViewProvider(viewProgress, buttonProgress)
    }
}

extension FeedState {
    static var sortingByModified: (Item, Item) -> Bool = {
        $0.modifiedAt < $1.modifiedAt
    }

    mutating func removedById(_ uuid: UUID) {
        items.removeAll { $0.id == uuid }
    }
}
