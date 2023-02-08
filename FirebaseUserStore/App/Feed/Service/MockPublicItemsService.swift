import Combine
import Firebase
import FirebaseFirestore

final class MockPublicItemsService: ItemsServiceType {
    typealias ServiceError = ItemsServiceError

    func fetchItems(_ query: ResponceType.DataType, filter: (Item) -> Bool) -> AnyPublisher<[Item], ItemsServiceError> {
        Deferred {
            Future { promise in
                let items = query.data.isEmpty ? mockItems : mockItems.filter { $0.title.contains(query.data) }
                return promise(.success(items))
            }
        }
        .delay(for: .seconds(3), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchQuery() -> AnyPublisher<MockFetchedResponce, ItemsServiceError> {
        Deferred {
            Future { promise in
                return promise(.success(MockFetchedResponce(query: MockFetchedResponce.MockQuery(data: String()), count: mockItems.count )))
            }
        }
        .delay(for: .seconds(3), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func searchQuery(_ text: String) -> AnyPublisher<MockFetchedResponce, ItemsServiceError> {
        Deferred {
            Future { promise in
                return promise(.success(MockFetchedResponce(query: MockFetchedResponce.MockQuery(data: text), count: 0 )))
            }
        }
        .delay(for: .seconds(3), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchItem(_ id: UUID) -> AnyPublisher<Item, ItemsServiceError> {
        Deferred {
            Future { promise in
                return promise(.failure(.writeNewItemFailure))
            }
        }.eraseToAnyPublisher()
    }

    func setNewItemRequest() -> AnyPublisher<UUID, ItemsServiceError> {
        Deferred {
            Future { promise in
                return promise(.failure(.writeNewItemFailure))
            }
        }.eraseToAnyPublisher()
    }

    func removeItemRequest(_ id: UUID) -> AnyPublisher<UUID, ItemsServiceError> {
        Deferred {
            Future { promise in
                return promise(.failure(.deleteItem))
            }
        }.eraseToAnyPublisher()
    }
}
