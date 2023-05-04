import Foundation

enum CreateAction {
    case linkRequest(_ link: String)
    case uploadNewItem(_ item: Item)

    case clickLinkField

    case showError(_ error: CreateState.CreateErrorType)
}

extension CreateAction: Action, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: self))
    }

    static func == (lhs: CreateAction, rhs: CreateAction) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
