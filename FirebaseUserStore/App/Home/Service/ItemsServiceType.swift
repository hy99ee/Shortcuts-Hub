import Combine
import Foundation

protocol ItemsServiceType {
    func fetchDishesByUserRequest() -> AnyPublisher<[Item], ItemsServiceError>
    func fetchItemByID(_ id: UUID) -> AnyPublisher<Item, ItemsServiceError>

    func setNewItemRequest() -> AnyPublisher<UUID, ItemsServiceError>
    func removeItemRequest(_ id: UUID) -> AnyPublisher<UUID, ItemsServiceError>
}

enum ItemsServiceError: Error {
    case firebaseError(_ error: Error)
    case invalidUserId
    
    case writeNewItemFailure
    case deleteItem

    case unknownError
    case mockError
}
extension ItemsServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidUserId:
            return NSLocalizedString(
                "The provided password is not valid.",
                comment: "Invalid Password"
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
        }
    }
}
