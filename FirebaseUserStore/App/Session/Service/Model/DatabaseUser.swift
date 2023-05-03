import Foundation

struct DatabaseUser: Equatable {
    let firstName: String
    let lastName: String
    let phone: String
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
