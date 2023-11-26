import Foundation

struct IdsSection: Identifiable, Equatable {
    let id: UUID

    let title: String
    let subtitle: String
    var titleIcons: [Data]

    var itemsIds: [String]
}

struct ItemsSection: Identifiable {
    let id: UUID
    let items: [Item]
}

extension IdsSection {
    static var mockSections: [IdsSection] = [
        IdsSection(
            id: UUID(),
            title: "Title",
            subtitle: "Subtitle",
            titleIcons: [],
            itemsIds: [
                Item.mockItems[0].id.uuidString,
                Item.mockItems[1].id.uuidString,
                Item.mockItems[2].id.uuidString,
                Item.mockItems[3].id.uuidString
            ]
        )
    ]
}
