import Foundation

protocol ItemType: Codable, Equatable, Identifiable, Hashable {
    var title: String { get }
}

struct Item: ItemType, Codable, Equatable, Identifiable, Hashable {
    var id: UUID
    var userId: String

    var title: String
    var aboutLink: String
    var source: String = ""

    var createdAt: Date
    var modifiedAt: Date?
}

var mockItems: [Item] = [
    Item(id: UUID(), userId: "UserId_1", title: "Item_1", aboutLink: "", source: "", createdAt: Date()),
    Item(id: UUID(), userId: "UserId_2", title: "Item_2", aboutLink: "", source: "", createdAt: Date()),
    Item(id: UUID(), userId: "UserId_3", title: "Item_3", aboutLink: "", source: "", createdAt: Date()),
    Item(id: UUID(), userId: "UserId_4", title: "Item_4", aboutLink: "", source: "", createdAt: Date()),
    Item(id: UUID(), userId: "UserId_5", title: "Item_5", aboutLink: "", source: "", createdAt: Date()),
    Item(id: UUID(), userId: "UserId_6", title: "Item_5", aboutLink: "", source: "", createdAt: Date()),
    Item(id: UUID(), userId: "UserId_7", title: "Item_6", aboutLink: "", source: "", createdAt: Date()),
    Item(id: UUID(), userId: "UserId_8", title: "Item_7", aboutLink: "", source: "", createdAt: Date()),
    Item(id: UUID(), userId: "UserId_9", title: "Item_8", aboutLink: "", source: "", createdAt: Date()),
    Item(id: UUID(), userId: "UserId_10", title: "Item_9", aboutLink: "", source: "", createdAt: Date()),
    Item(id: UUID(), userId: "UserId_11", title: "Item_10", aboutLink: "", source: "", createdAt: Date()),
    Item(id: UUID(), userId: "UserId_12", title: "Item_11", aboutLink: "", source: "", createdAt: Date()),
    Item(id: UUID(), userId: "UserId_13", title: "Item_12", aboutLink: "", source: "", createdAt: Date()),
    Item(id: UUID(), userId: "UserId_14", title: "Item_13", aboutLink: "", source: "", createdAt: Date()),
    Item(id: UUID(), userId: "UserId_15", title: "Item_14", aboutLink: "", source: "", createdAt: Date()),
    Item(id: UUID(), userId: "UserId_16", title: "Item_15", aboutLink: "", source: "", createdAt: Date()),
    Item(id: UUID(), userId: "UserId_17", title: "Item_16", aboutLink: "", source: "", createdAt: Date()),
    Item(id: UUID(), userId: "UserId_18", title: "Item_17", aboutLink: "", source: "", createdAt: Date()),
]
