import Combine
import Firebase
import FirebaseFirestore

class ItemsService: ItemsServiceType {
    typealias ServiceError = ItemsServiceError
    typealias ResponceType = FetchedResponce

    func fetchQuery() -> AnyPublisher<FetchedResponce, ItemsServiceError> {
        fatalError("Not implemented")
    }
    
    func searchQuery(_ text: String) -> AnyPublisher<FetchedResponce, ItemsServiceError> {
        fatalError("Not implemented")
    }
    
    func fetchItem(_ id: UUID) -> AnyPublisher<Item, ItemsServiceError> {
        fatalError("Not implemented")
    }
    
    func setNewItemRequest() -> AnyPublisher<UUID, ItemsServiceError> {
        fatalError("Not implemented")
    }
    
    func removeItemRequest(_ id: UUID) -> AnyPublisher<UUID, ItemsServiceError> {
        fatalError("Not implemented")
    }
}
