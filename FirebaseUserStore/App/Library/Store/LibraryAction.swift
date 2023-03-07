import Foundation

enum LibraryAction: Action, Hashable {
    case updateLibrary
    case next

    case search(text: String)
    case cancelSearch

    case click(_ item: Item)

    case addItems(items: [Item])
    case updateItem(id: UUID)
    case removeItem(id: UUID)

    case changeSearchField(_ newText: String)

    case showAboutSheet
    case showAlert(error: Error)
    case showLibraryError

    case userLoginState(_ state: SessionState)
    case openLogin

    case logout
    case deleteUser

    case mockAction

    func hash(into hasher: inout Hasher) {
        switch self {
        case .updateLibrary:
            hasher.combine(0)
        case .click:
            hasher.combine(2)
        case .addItems:
            hasher.combine(3)
        case .updateItem:
            hasher.combine(33)
        case .removeItem:
            hasher.combine(5)
        case .search:
            hasher.combine(6)
        case .showAboutSheet:
            hasher.combine(8)
        case .showAlert:
            hasher.combine(9)
        case .showLibraryError:
            hasher.combine(10)
        case .logout:
            hasher.combine(11)
        case .deleteUser:
            hasher.combine(12)
        case .userLoginState:
            hasher.combine(13)
        case .openLogin:
            hasher.combine(14)
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

    static func == (lhs: LibraryAction, rhs: LibraryAction) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
