import Combine
import Firebase
import FirebaseFirestore

protocol ItemsServiceType {
    associatedtype ServiceError: Error
    associatedtype ResponceType: FetchedResponceType

    func fetchItems(_ query: ResponceType.DataType) -> AnyPublisher<[Item], ItemsServiceError>
    func fetchQuery() -> AnyPublisher<ResponceType, ItemsServiceError>
    func searchQuery(_ text: String) -> AnyPublisher<ResponceType, ItemsServiceError>
    func fetchItem(_ id: UUID) -> AnyPublisher<Item, ItemsServiceError>
}
