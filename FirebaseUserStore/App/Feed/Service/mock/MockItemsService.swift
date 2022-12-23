import Combine
import Firebase
import FirebaseFirestore

final class MockItemsService: ItemsServiceType {
    typealias ServiceError = ItemsServiceError

    func fetchItems(_ query: ResponceType.DataType) -> AnyPublisher<[Item], ItemsServiceError> {
        Deferred {
            Future { promise in
                let items = query.data.isEmpty ? mockItems : mockItems.filter { $0.title.contains(query.data) && !query.local.contains($0.id) }
                return promise(.success(items))
            }
        }
        .delay(for: .seconds(3), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchQuery() -> AnyPublisher<MockFetchedResponce, ItemsServiceError> {
        Deferred {
            Future { promise in
                return promise(.success(MockFetchedResponce(query: MockFetchedResponce.MockQuery(data: String(), local: Set()), count: mockItems.count )))
            }
        }
        .delay(for: .seconds(3), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func searchQuery(_ text: String, local: Set<UUID>) -> AnyPublisher<MockFetchedResponce, ItemsServiceError> {
        Deferred {
            Future { promise in
                return promise(.success(MockFetchedResponce(query: MockFetchedResponce.MockQuery(data: text, local: local), count: mockItems.filter { $0.title.contains(text) && !local.contains($0.id) }.count )))
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
