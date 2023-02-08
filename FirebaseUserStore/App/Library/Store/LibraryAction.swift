import Foundation

enum LibraryAction: Action, Hashable {
    case updateLibrary

    case click(_ item: Item)

    case addItems(items: [Item])
    case addItem
    case removeItem(id: UUID)
    case search(text: String, local: Set<UUID> = Set())
    case clean

    case showAboutSheet
    case showAlert(error: Error)
    case showLibraryError

    case logout

    case mockAction

    func hash(into hasher: inout Hasher) {
        switch self {
        case .updateLibrary:
            hasher.combine(0)
        case .click:
            hasher.combine(1)
        case .addItems:
            hasher.combine(2)
        case .addItem:
            hasher.combine(3)
        case .removeItem:
            hasher.combine(4)
        case .search:
            hasher.combine(5)
        case .clean:
            hasher.combine(6)
        case .showAboutSheet:
            hasher.combine(7)
        case .showAlert:
            hasher.combine(8)
        case .showLibraryError:
            hasher.combine(7)
        case .logout:
            hasher.combine(9)
        case .mockAction:
            hasher.combine(10)
        }
    }

    static func == (lhs: LibraryAction, rhs: LibraryAction) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
