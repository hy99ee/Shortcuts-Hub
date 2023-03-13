import Foundation


struct LoaderItem: Codable, Hashable, Identifiable {
    var id: Int
//    { Int.random(in: Int.min...Int.max) }
    var title = "Loading..."
}
