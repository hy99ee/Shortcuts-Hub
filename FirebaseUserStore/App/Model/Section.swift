import Foundation

struct IdsSection: Identifiable, Equatable {
    let id: UUID

    let title: String
    let subtitle: String?
    var titleIcons: [URL]

    var itemsIds: [String]
}

struct ItemsSection: Identifiable {
    let id: UUID

    let title: String
    let subtitle: String?

    let items: [Item]
}
