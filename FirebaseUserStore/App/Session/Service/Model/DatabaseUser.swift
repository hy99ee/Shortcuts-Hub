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

    var savedIdWithLimitations: [[String]] {
        savedIds.chunked(into: 9)
    }

    var databaseFormat: [String: Any] {
        [
            DatabaseUserKeys.firstName.rawValue: self.firstName,
            DatabaseUserKeys.lastName.rawValue: self.lastName,
            DatabaseUserKeys.phone.rawValue: self.phone,
            DatabaseUserKeys.savedIds.rawValue: self.savedIds
        ]
    }
}

enum DatabaseUserMutation: Equatable {
    case add(item: Item)
    case remove(item: Item)

    static func == (lhs: Self, rhs: Self) -> Bool {
        switch lhs {
        case let .add(lItem):
            if case let .add(rItem) = rhs {
                return lItem.id == rItem.id
            } else {
                return false
            }

        case let .remove(lItem):
            if case let .remove(rItem) = rhs {
                return lItem.id == rItem.id
            } else {
                return false
            }
        }
    }
}
