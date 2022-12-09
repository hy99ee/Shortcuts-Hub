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
//
//extension FeedState {
//    struct MockFeedState: StateType {
//        var items: [Item] = [
//            Item(id: UUID(), userId: "UserId_1", title: "Item_1", description: "", source: ""),
//            Item(id: UUID(), userId: "UserId_2", title: "Item_1", description: "", source: ""),
//            Item(id: UUID(), userId: "UserId_3", title: "Item_1", description: "", source: ""),
//            Item(id: UUID(), userId: "UserId_4", title: "Item_1", description: "", source: ""),
//            Item(id: UUID(), userId: "UserId_5", title: "Item_1", description: "", source: ""),
//            Item(id: UUID(), userId: "UserId_6", title: "Item_1", description: "", source: ""),
//            Item(id: UUID(), userId: "UserId_7", title: "Item_1", description: "", source: ""),
//            Item(id: UUID(), userId: "UserId_8", title: "Item_1", description: "", source: ""),
//            Item(id: UUID(), userId: "UserId_9", title: "Item_1", description: "", source: ""),
//            Item(id: UUID(), userId: "UserId_10", title: "Item_1", description: "", source: ""),
//            Item(id: UUID(), userId: "UserId_11", title: "Item_1", description: "", source: ""),
//            Item(id: UUID(), userId: "UserId_12", title: "Item_1", description: "", source: ""),
//            Item(id: UUID(), userId: "UserId_13", title: "Item_1", description: "", source: ""),
//            Item(id: UUID(), userId: "UserId_14", title: "Item_1", description: "", source: ""),
//            Item(id: UUID(), userId: "UserId_15", title: "Item_1", description: "", source: ""),
//            Item(id: UUID(), userId: "UserId_16", title: "Item_1", description: "", source: ""),
//            Item(id: UUID(), userId: "UserId_17", title: "Item_1", description: "", source: ""),
//            Item(id: UUID(), userId: "UserId_18", title: "Item_1", description: "", source: ""),
//        ]
//
//        var itemsPreloadersCount = 0 {
//            didSet {
//                loadItems = Array(repeating: LoaderItem(), count: itemsPreloadersCount)
//            }
//        }
//
//        var loadItems: [LoaderItem] = []
//        var showEmptyView = false
//
//        var alert = AlertProvider()
//        var aboutSheetProvider = SheetProvider<AboutView>(presentationDetent: [.height(200), .medium])
//
//        var viewProgress = ProgressViewProvider()
//        var buttonProgress = ProgressViewProvider()
//
//        let processViewProgress: ProcessViewProvider
//
//        init() {
//            processViewProgress = ProcessViewProvider(viewProgress, buttonProgress)
//        }
//    }
//}
