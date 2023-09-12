import Foundation

// MARK: Collection delegate
extension SavedStore: CollectionDelegate {
    var navigationTitle: String { "Saved" }

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

    func update() {
        self.dispatch(.updateSaved)
    }

    func search(_ text: String) {
        self.dispatch(.search(text: text))
    }

    func click(_ item: Item) {
        self.dispatch(.click(item))
    }

    func remove(_ item: Item) {
        self.dispatch(.removeFromSaved(item: item))
    }

    func next() {
        self.dispatch(.next)
    }

    func isItemRemoving(_ item: Item) -> Bool {
        state.itemsRemovingQueue.contains(item.id)
    }
}
