import Foundation

struct Item: Codable, Equatable, Identifiable {
    var id: UUID
    var userId: String
    var title: String
    var description: String
    var source: String
}
