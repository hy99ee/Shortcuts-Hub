import Foundation


struct LoaderItem: Codable, Equatable, Hashable, Identifiable {
    var id = UUID()
    var title = "Loading..."
}
