import Foundation

protocol ItemType: Codable, Equatable, Identifiable, Hashable {
    var id: UUID { get }
    var title: String { get }
}

// MARK: - Item
struct Item: ItemType, Codable, Equatable, Identifiable, Hashable {
    var id: UUID
    var userId: String

    var title: String
    var description: String

    var colorValue: Int?
    var icon: Data?
    var idioms: [SupportedIdioms] = []

    var originalUrl: String?

    var isSaved: Bool { SessionService.shared.userDetails.savedIds.contains(id.uuidString) }
    var validateByAdmin: Int = ItemValidateStatus.undefined.rawValue

    var createdAt: Date
    var modifiedAt: Date?

    var tags: [String] { title.generateStringSequence() + description.generateStringSequence() }
}

enum SupportedIdioms: String, Codable {
    case desktop = "Desktop"
    case phone = "Phone"
    case pad = "Pad"
}

enum ItemValidateStatus: Int, Codable {
    case undefined
    case approve
    case decline
}

extension Item {
    static var mockItems: [Item] = [
        Item(id: UUID(), userId: "user_id_0", title: "Moc_title_0", description: "Mock_description_1", originalUrl: "https://mock.com", createdAt: Date()),
        Item(id: UUID(), userId: "user_id_1", title: "Moc_title_1", description: "Mock_description_1", originalUrl: "https://mock.com", createdAt: Date()),
        Item(id: UUID(), userId: "user_id_2", title: "Moc_title_2", description: "Mock_description_2", originalUrl: "https://mock.com", createdAt: Date()),
        Item(id: UUID(), userId: "user_id_3", title: "Moc_title_3", description: "Mock_description_3", originalUrl: "https://mock.com", createdAt: Date()),
        Item(id: UUID(), userId: "user_id_4", title: "Moc_title_4", description: "Mock_description_4", originalUrl: "https://mock.com", createdAt: Date()),
        Item(id: UUID(), userId: "user_id_5", title: "Moc_title_5", description: "Mock_description_5", originalUrl: "https://mock.com", createdAt: Date()),
        Item(id: UUID(), userId: "user_id_6", title: "Moc_title_6", description: "Mock_description_6", originalUrl: "https://mock.com", createdAt: Date()),
        Item(id: UUID(), userId: "user_id_7", title: "Moc_title_7", description: "Mock_description_7", originalUrl: "https://mock.com", createdAt: Date()),
        Item(id: UUID(), userId: "user_id_8", title: "Moc_title_8", description: "Mock_description_8", originalUrl: "https://mock.com", createdAt: Date()),
        Item(id: UUID(), userId: "user_id_9", title: "Moc_title_9", description: "Mock_description_9", originalUrl: "https://mock.com", createdAt: Date()),
        Item(id: UUID(), userId: "user_id_10", title: "Moc_title_10", description: "Mock_description_10", originalUrl: "https://mock.com", createdAt: Date()),
        Item(id: UUID(), userId: "user_id_11", title: "Moc_title_11", description: "Mock_description_11", originalUrl: "https://mock.com", createdAt: Date()),
        Item(id: UUID(), userId: "user_id_12", title: "Moc_title_12", description: "Mock_description_12", originalUrl: "https://mock.com", createdAt: Date()),
        Item(id: UUID(), userId: "user_id_13", title: "Moc_title_13", description: "Mock_description_13", originalUrl: "https://mock.com", createdAt: Date()),
        Item(id: UUID(), userId: "user_id_14", title: "Moc_title_14", description: "Mock_description_14", originalUrl: "https://mock.com", createdAt: Date()),
        Item(id: UUID(), userId: "user_id_15", title: "Moc_title_15", description: "Mock_description_15", originalUrl: "https://mock.com", createdAt: Date()),
        Item(id: UUID(), userId: "user_id_16", title: "Moc_title_16", description: "Mock_description_16", originalUrl: "https://mock.com", createdAt: Date()),
        Item(id: UUID(), userId: "user_id_17", title: "Moc_title_17", description: "Mock_description_17", originalUrl: "https://mock.com", createdAt: Date()),
        Item(id: UUID(), userId: "user_id_18", title: "Moc_title_18", description: "Mock_description_18", originalUrl: "https://mock.com", createdAt: Date()),
        Item(id: UUID(), userId: "user_id_19", title: "Moc_title_19", description: "Mock_description_19", originalUrl: "https://mock.com", createdAt: Date()),
        Item(id: UUID(), userId: "user_id_20", title: "Moc_title_20", description: "Mock_description_20", originalUrl: "https://mock.com", createdAt: Date()),
        Item(id: UUID(), userId: "user_id_21", title: "Moc_title_21", description: "Mock_description_21", originalUrl: "https://mock.com", createdAt: Date()),
        Item(id: UUID(), userId: "user_id_22", title: "Moc_title_22", description: "Mock_description_22", originalUrl: "https://mock.com", createdAt: Date())

        //    Item(id: UUID(), userId: "user_id_0", title: "Moc_title_0", description: "Mock_description_1", createdAt: Timestamp()),
        //    Item(id: UUID(), userId: "user_id_1", title: "Moc_title_1", description: "Mock_description_1", createdAt: Timestamp()),
        //    Item(id: UUID(), userId: "user_id_2", title: "Moc_title_2", description: "Mock_description_2", createdAt: Timestamp()),
        //    Item(id: UUID(), userId: "user_id_3", title: "Moc_title_3", description: "Mock_description_3", createdAt: Timestamp()),
        //    Item(id: UUID(), userId: "user_id_4", title: "Moc_title_4", description: "Mock_description_4", createdAt: Timestamp()),
        //    Item(id: UUID(), userId: "user_id_5", title: "Moc_title_5", description: "Mock_description_5", createdAt: Timestamp()),
        //    Item(id: UUID(), userId: "user_id_6", title: "Moc_title_6", description: "Mock_description_6", createdAt: Timestamp()),
        //    Item(id: UUID(), userId: "user_id_7", title: "Moc_title_7", description: "Mock_description_7", createdAt: Timestamp()),
        //    Item(id: UUID(), userId: "user_id_8", title: "Moc_title_8", description: "Mock_description_8", createdAt: Timestamp()),
        //    Item(id: UUID(), userId: "user_id_9", title: "Moc_title_9", description: "Mock_description_9", createdAt: Timestamp()),
        //    Item(id: UUID(), userId: "user_id_10", title: "Moc_title_10", description: "Mock_description_10", createdAt: Timestamp()),
        //    Item(id: UUID(), userId: "user_id_11", title: "Moc_title_11", description: "Mock_description_11", createdAt: Timestamp()),
        //    Item(id: UUID(), userId: "user_id_12", title: "Moc_title_12", description: "Mock_description_12", createdAt: Timestamp()),
        //    Item(id: UUID(), userId: "user_id_13", title: "Moc_title_13", description: "Mock_description_13", createdAt: Timestamp()),
        //    Item(id: UUID(), userId: "user_id_14", title: "Moc_title_14", description: "Mock_description_14", createdAt: Timestamp()),
        //    Item(id: UUID(), userId: "user_id_15", title: "Moc_title_15", description: "Mock_description_15", createdAt: Timestamp()),
        //    Item(id: UUID(), userId: "user_id_16", title: "Moc_title_16", description: "Mock_description_16", createdAt: Timestamp()),
        //    Item(id: UUID(), userId: "user_id_17", title: "Moc_title_17", description: "Mock_description_17", createdAt: Timestamp()),
        //    Item(id: UUID(), userId: "user_id_18", title: "Moc_title_18", description: "Mock_description_18", createdAt: Timestamp()),
        //    Item(id: UUID(), userId: "user_id_19", title: "Moc_title_19", description: "Mock_description_19", createdAt: Timestamp()),
        //    Item(id: UUID(), userId: "user_id_20", title: "Moc_title_20", description: "Mock_description_20", createdAt: Timestamp()),
        //    Item(id: UUID(), userId: "user_id_21", title: "Moc_title_21", description: "Mock_description_21", createdAt: Timestamp()),
        //    Item(id: UUID(), userId: "user_id_22", title: "Moc_title_22", description: "Mock_description_22", createdAt: Timestamp())
    ]
}
