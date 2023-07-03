import Foundation

enum ItemsServiceError: Error {
    case unauth

    case firebaseError(_ error: Error)
    case appleError(_ error: Error)
    case userDatabaseError
    case withDecode

    case invalidUserId
    case invalidSnapshot
    
    case writeNewItemFailure
    case deleteItem
    case receiveAppleItem

    case unknownError

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
            
        case let .firebaseError(error):
            return error.localizedDescription

        case let .appleError(error):
            return error.localizedDescription

        case .userDatabaseError:
            return NSLocalizedString(
                "Error with update user data",
                comment: "Resource Not Found"
            )
            
        case .unknownError:
            return NSLocalizedString(
                "An unexpected error occurred.",
                comment: "Unexpected Error"
            )
            
        case .withDecode:
            return NSLocalizedString(
                "Error with decoding.",
                comment: "Mock Error"
            )

        case .receiveAppleItem:
            return NSLocalizedString(
                "Receive shortcut item from Apple failure.",
                comment: "Mock Error"
            )

        case .none:
            return ""
        }
    }
}
