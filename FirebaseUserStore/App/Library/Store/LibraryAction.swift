import Foundation

enum LibraryAction: Action, Hashable {
    case updateLibrary
    case updateLocalLibrary

    case click(_ item: Item)

    case addItems(items: [Item])
    case addItem
    case removeItem(id: UUID)
    case search(text: String, local: Set<UUID> = Set())
    case clean

    case showAboutSheet
    case showAlert(error: Error)
    case showLibraryError

    case userLoginState(_ state: SessionState)
    case openLogin
    case logout

    case mockAction

    func hash(into hasher: inout Hasher) {
        switch self {
        case .updateLibrary:
            hasher.combine(0)
        case .updateLocalLibrary:
            hasher.combine(1)
        case .click:
            hasher.combine(2)
        case .addItems:
            hasher.combine(3)
        case .addItem:
            hasher.combine(4)
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
        case .userLoginState:
            hasher.combine(12)
        case .openLogin:
            hasher.combine(13)
        case .mockAction:
            hasher.combine(13)
        }
    }

    static func == (lhs: LibraryAction, rhs: LibraryAction) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
