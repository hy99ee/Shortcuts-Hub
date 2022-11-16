import Foundation

struct Item: Codable, Equatable, Identifiable, Hashable {
    var id: UUID
    var createAt: Date
    var modifiedAt: Date
    var userId: String
    var title: String
    var description: String
    var source: String
    
    init(id: UUID, createAt: Date = Date(), modifiedAt: Date? = nil, userId: String, title: String, description: String, source: String) {
        self.id = id
        self.createAt = createAt
        self.modifiedAt = modifiedAt ?? createAt
        self.userId = userId
        self.title = title
        self.description = description
        self.source = source
    }
}
