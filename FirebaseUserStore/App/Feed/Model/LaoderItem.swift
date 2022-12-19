import Foundation


struct LoaderItem: Codable, Equatable, Identifiable {
    var id: UUID {
        UUID()
    }
    var title = "Loading..."
}
