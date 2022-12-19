import Foundation

protocol ItemType: Codable, Equatable, Identifiable, Hashable {
    var title: String { get }
}

struct Item: ItemType, Codable, Equatable, Identifiable, Hashable {
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

var mockItems: [Item] = [
    Item(id: UUID(), userId: "UserId_1", title: "Item_1", description: "", source: ""),
    Item(id: UUID(), userId: "UserId_2", title: "Item_1", description: "", source: ""),
    Item(id: UUID(), userId: "UserId_3", title: "Item_1", description: "", source: ""),
    Item(id: UUID(), userId: "UserId_4", title: "Item_1", description: "", source: ""),
    Item(id: UUID(), userId: "UserId_5", title: "Item_1", description: "", source: ""),
    Item(id: UUID(), userId: "UserId_6", title: "Item_1", description: "", source: ""),
    Item(id: UUID(), userId: "UserId_7", title: "Item_1", description: "", source: ""),
    Item(id: UUID(), userId: "UserId_8", title: "Item_1", description: "", source: ""),
    Item(id: UUID(), userId: "UserId_9", title: "Item_1", description: "", source: ""),
    Item(id: UUID(), userId: "UserId_10", title: "Item_1", description: "", source: ""),
    Item(id: UUID(), userId: "UserId_11", title: "Item_1", description: "", source: ""),
    Item(id: UUID(), userId: "UserId_12", title: "Item_1", description: "", source: ""),
    Item(id: UUID(), userId: "UserId_13", title: "Item_1", description: "", source: ""),
    Item(id: UUID(), userId: "UserId_14", title: "Item_1", description: "", source: ""),
    Item(id: UUID(), userId: "UserId_15", title: "Item_1", description: "", source: ""),
    Item(id: UUID(), userId: "UserId_16", title: "Item_1", description: "", source: ""),
    Item(id: UUID(), userId: "UserId_17", title: "Item_1", description: "", source: ""),
    Item(id: UUID(), userId: "UserId_18", title: "Item_1", description: "", source: ""),
]
