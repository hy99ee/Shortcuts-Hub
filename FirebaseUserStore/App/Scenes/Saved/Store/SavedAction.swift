import Foundation

enum SavedAction: Action, Hashable {
    case initSaved
    case updateSaved
    case next

    case search(text: String)
    case changeSearchField(_ newText: String)

    case updateItem(id: UUID)

    case click(_ item: Item)

    case showAlert(error: Error)
    case showSavedError

    case mockAction

    func hash(into hasher: inout Hasher) {
        switch self {
        case .initSaved:
            hasher.combine(0)
        case .updateSaved:
            hasher.combine(1)
        case .click:
            hasher.combine(2)
        case .search:
            hasher.combine(3)
        case .showAlert:
            hasher.combine(4)
        case .showSavedError:
            hasher.combine(5)
        case .changeSearchField:
            hasher.combine(6)
        case .mockAction:
            hasher.combine(7)
        case .next:
            hasher.combine(8)
        case .updateItem:
            hasher.combine(9)
        }
    }

    static func == (lhs: SavedAction, rhs: SavedAction) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
