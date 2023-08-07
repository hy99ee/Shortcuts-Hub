import Foundation

// MARK: - AppleApiItem
struct AppleApiItem: Codable {
    let fields: Fields
    let recordChangeTag: String
    let deleted: Bool
    let modified: Created
    let recordName, recordType: String
    let pluginFields: PluginFields
    let created: Created
}

struct Created: Codable {
    let deviceID: String
    let timestamp: Int
    let userRecordName: String
}

struct Fields: Codable {
    let icon, signedShortcut: Icon
    let iconColor: IconColor
    let shortcut: Icon
    let iconGlyph: IconColor
    let name: Name
    let signingCertificateExpirationDate: IconColor
    let signingStatus: Name

    enum CodingKeys: String, CodingKey {
        case icon, signedShortcut
        case iconColor = "icon_color"
        case shortcut
        case iconGlyph = "icon_glyph"
        case name, signingCertificateExpirationDate, signingStatus
    }
}

struct Icon: Codable {
    let type: String
    let value: Value
}

struct Value: Codable {
    let downloadURL, fileChecksum: String
    let size: Int
}

struct IconColor: Codable {
    let type: String
    let value: Int
}

struct Name: Codable {
    let type, value: String
}

struct PluginFields: Codable {}

extension AppleApiItem: Equatable {
    static func == (lhs: AppleApiItem, rhs: AppleApiItem) -> Bool {
        lhs.fields.name.value == rhs.fields.name.value
    }
}
