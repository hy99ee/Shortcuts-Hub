import Foundation

// MARK: Collection delegate
extension LibraryStore: CollectionDelegate {
    var navigationTitle: String { "Library" }

    var items: [Item] {
        state.items
    }

    var loadingItems: [LoaderItem]? {
        state.loadingItems
    }

    var searchedItems: [Item]? {
        state.searchedItems
    }

    var viewProgress: ProgressViewStatus {
        state.viewProgress
    }

    var toolbarItems: [ToolbarCollectionItem] {
        [
            ToolbarCollectionItem(iconName: "person") { self.dispatch(.showAboutSheet) }
        ]
    }

    func update() {
        self.dispatch(.updateLibrary)
    }

    func search(_ text: String) {
        self.dispatch(.search(text: text))
    }

    func click(_ item: Item) {
        self.dispatch(.click(item))
    }

    func remove(_ item: Item) {
        self.dispatch(.removeFromLibrary(item: item))
    }

    func next() {
        self.dispatch(.next)
    }

    func isItemRemoving(_ item: Item) -> Bool {
        state.itemsRemovingQueue.contains(item.id)
    }
}
