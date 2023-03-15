import Foundation

enum SavedAction: Action, Hashable {
    case initSaved
    case updateSaved
    case next

    case search(text: String)
    case cancelSearch

    case click(_ item: Item)

    case changeSearchField(_ newText: String)

    case showAlert(error: Error)
    case showSavedError

    case mockAction

    func hash(into hasher: inout Hasher) {
        switch self {
        case .initSaved:
            hasher.combine(-1)
        case .updateSaved:
            hasher.combine(0)
        case .click:
            hasher.combine(2)
        case .search:
            hasher.combine(6)
        case .showAlert:
            hasher.combine(9)
        case .showSavedError:
            hasher.combine(10)
        case .changeSearchField:
            hasher.combine(15)
        case .mockAction:
            hasher.combine(16)
        case .next:
            hasher.combine(17)
        case .cancelSearch:
            hasher.combine(18)
        }
    }

    static func == (lhs: SavedAction, rhs: SavedAction) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
