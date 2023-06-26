import Foundation

enum LibraryAction: Action, Hashable {
    case initLibrary
    case updateLibrary
    case next

    case search(text: String)
    case changeSearchField(_ newText: String)

    case click(_ item: Item)

    case addItem(_ item: Item)
    case removeItem(_ item: Item)

    case removeFromLibrary(item: Item)

    case showAboutSheet
    case showAlert(error: Error)
    case showLibraryError

    case userLoginState(_ state: SessionState)
    case openLogin

    case logout
    case deleteUser

    case mockAction

    func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: self))
    }

    static func == (lhs: LibraryAction, rhs: LibraryAction) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
