import Foundation

enum DetailItemAction: Action, Hashable {
    case addToSaved
    case removeFromSaved
    case itemByOperation(item: Item, operation: DetailItemStore.Operation)

    func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: self))
    }

    static func == (lhs: DetailItemAction, rhs: DetailItemAction) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}


