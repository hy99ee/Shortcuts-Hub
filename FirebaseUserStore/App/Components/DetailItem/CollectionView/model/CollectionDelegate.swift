import Foundation
import Combine

struct ToolbarCollectionItem: Identifiable {
    let id = UUID()
    let iconName: String
    let action: () -> ()

    static func == (lhs: ToolbarCollectionItem, rhs: ToolbarCollectionItem) -> Bool {
        lhs.iconName == rhs.iconName
    }
}

protocol CollectionDelegate: ObservableObject {
    var navigationTitle: String { get }

    var items: [Item] { get }
    var preloadItems: [LoaderItem]? { get }
    var searchedItems: [Item]? { get }

    var viewProgress: ProgressViewStatus { get }
    var toolbarItems: [ToolbarCollectionItem] { get }

    func update() async
    func search(_ text: String) async
    func next() async

    func click(_ item: Item)
    func remove(_ item: Item)
    func isItemRemoving(_ item: Item) -> Bool
}
