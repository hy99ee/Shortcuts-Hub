import Foundation
enum DatabaseUserKeys: String {
    case firstName
    case lastName
    case phone
    case savedIds
}

struct DatabaseUser: Equatable {
    let firstName: String
    let lastName: String
    let phone: String
    var savedIds: [String]

    var databaseFormat: [String: Any] {
        [
            DatabaseUserKeys.firstName.rawValue: self.firstName,
            DatabaseUserKeys.lastName.rawValue: self.lastName,
            DatabaseUserKeys.phone.rawValue: self.phone,
            DatabaseUserKeys.savedIds.rawValue: self.savedIds
        ]
    }
}

enum DatabaseUserMutation {
    case addIds(_ id: String)
    case removeIds(_ id: String)
}
