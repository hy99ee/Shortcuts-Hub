import Foundation

enum LibraryAction: Action, Hashable {
    case updateLibrary

    case click(_ item: Item)

    case addItems(items: [Item])
    case removeItem(id: UUID)
    case search(text: String)
    case clean
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
        case .removeItem:
            hasher.combine(5)
        case .search:
            hasher.combine(6)
        case .clean:
            hasher.combine(7)
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
        }
    }

    static func == (lhs: LibraryAction, rhs: LibraryAction) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
