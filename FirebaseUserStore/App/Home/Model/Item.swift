import Foundation

struct Item: Codable, Equatable, Identifiable, Hashable {
    var id: UUID
    var userId: String
    var title: String
    var description: String
    var source: String
}
