import Foundation

struct IdsSection: Identifiable {
    let id: UUID

    let title: String
    let subtitle: String?

    let itemsIds: [String]
}

struct ItemsSection: Identifiable {
    let id: UUID

    let title: String
    let subtitle: String?

    let items: [Item]
}
