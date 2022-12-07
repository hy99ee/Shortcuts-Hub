import Foundation

struct LoaderItem: ItemType, Codable, Equatable, Identifiable, Hashable {
    var id = UUID()
    var title = "Loading..."
}
