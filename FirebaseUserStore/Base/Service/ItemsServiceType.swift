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

extension ItemsServiceType {
    func fetchItems(_ query: Query) -> AnyPublisher<[Item], ItemsServiceError> {
        Deferred {
            Future { promise in
                query.getDocuments { snapshot, error in
                    if let _error = error {
                        return promise(.failure(.firebaseError(_error)))
                    }
                    guard let documents = snapshot?.documents else {
                        return promise(.success([]))
                    }
                    var items: [Item] = []
                    documents
                        .map { $0.data() }
                        .forEach { data in
                            items.append(
                                Item(
                                    id: UUID(uuidString: (data["id"] as? String ?? "")) ?? UUID(),
                                    userId: data["userId"] as? String ?? "",
                                    title: data["title"] as? String ?? "",
                                    iconUrl: URL(string: data["icon"] as? String ?? ""),
                                    description: data["description"] as? String ?? "",
                                    createdAt: Date()
                                )
                            )
                        }
                    return promise(.success(items))
                    
                }
            }
        }
        .delay(for: .milliseconds(250), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
