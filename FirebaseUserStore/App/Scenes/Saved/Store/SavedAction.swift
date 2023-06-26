import Foundation

enum SavedAction: Action, Hashable {
    case initSaved
    case initLocalSaved
    case updateSaved
    case updateLocalSaved
    case next

    case search(text: String)
    case localSearch(text: String)

    case changeSearchField(_ newText: String)

    case addToSaved(item: Item)
    case removeFromSaved(item: Item)

    case addItem(_ item: Item)
    case removeItem(_ item: Item)

    case click(_ item: Item)

    case showAlert(error: Error)
    case showSavedError

    case mockAction

    func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: self))
    }

    static func == (lhs: SavedAction, rhs: SavedAction) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
