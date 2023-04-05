import Foundation

enum CreateAction {
    case linkRequest(_ link: String)
    case uploadNewItem(_ item: Item)

    case clickLinkField

    case showError(_ error: CreateState.CreateErrorType)
}

extension CreateAction: Action, Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .linkRequest: hasher.combine(0)
        case .uploadNewItem: hasher.combine(1)
        case .clickLinkField: hasher.combine(2)
        case .showError: hasher.combine(3)
        }
    }

    static func == (lhs: CreateAction, rhs: CreateAction) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
