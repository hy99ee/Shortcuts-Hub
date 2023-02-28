import Foundation

protocol ItemType: Codable, Equatable, Identifiable, Hashable {
    var title: String { get }
}

enum SupportedIdioms: String, Codable {
    case desktop = "Desktop"
    case phone = "Phone"
    case pad = "Pad"
}

struct Item: ItemType, Codable, Equatable, Identifiable, Hashable {
    var id: UUID
    var userId: String

    var title: String
    var iconUrl: URL?
    var description: String
    var idioms: [SupportedIdioms] = []
//    var recordType: RecordType = .shared

    var createdAt: Date
    var modifiedAt: Date?

    var tags: [String] { title.generateStringSequence() + description.generateStringSequence() }
}

var mockItems: [Item] = [
    
]
