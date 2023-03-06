import Foundation

enum ItemsServiceError: Error {
    case unauth
    case firebaseError(_ error: Error)
    case invalidUserId
    case invalidSnapshot
    
    case writeNewItemFailure
    case deleteItem

    case unknownError
    case mockError

    case none
}

extension ItemsServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unauth:
            return nil

        case .invalidUserId:
            return NSLocalizedString(
                "The provided password is not valid.",
                comment: "Invalid Password"
            )
            
        case .invalidSnapshot:
            return NSLocalizedString(
                "Firebase snapshot is not valid.",
                comment: "Mock Error"
            )

        case .writeNewItemFailure:
            return NSLocalizedString(
                "Write new item fail.",
                comment: "Resource Not Found"
            )
            
        case .deleteItem:
            return NSLocalizedString(
                "Remove item fail.",
                comment: "Resource Not Found"
            )
            
        case .firebaseError:
            return NSLocalizedString(
                "The specified item could not be found.",
                comment: "Resource Not Found"
            )
            
        case .unknownError:
            return NSLocalizedString(
                "An unexpected error occurred.",
                comment: "Unexpected Error"
            )
            
        case .mockError:
            return NSLocalizedString(
                "This is message for testing receive errors messages.",
                comment: "Mock Error"
            )

        case .none:
            return ""
        }
    }
}
