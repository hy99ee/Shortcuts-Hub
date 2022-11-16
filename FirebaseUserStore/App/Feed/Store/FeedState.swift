import SwiftUI
import Combine

struct FeedState: StateWithAlert {
//    var items: [Item] = [Item(id: UUID(), userId: "ID", title: "Need to refresh", description: "Desc", source: "Source")]
    var items: [Item] = []
    var alertProvider = AlertProvider()
    var aboutSheetProvider = SheetProvider<AboutView>(presentationDetent: [.height(200), .medium])
}

extension FeedState {
    static var sortingByModified: (Item, Item) -> Bool = {
        $0.modifiedAt < $1.modifiedAt
    }

    mutating func removedById(_ uuid: UUID) {
        items.removeAll { $0.id == uuid }
    }
}
