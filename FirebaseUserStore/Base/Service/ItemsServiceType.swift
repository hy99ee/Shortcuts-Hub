import Combine
import Firebase
import FirebaseFirestore

protocol ItemsServiceType {
    associatedtype ServiceError: Error
    associatedtype ResponceType: FetchedResponceType

    func fetchItemsFromQuery(_ query: ResponceType.DataType, isPaginatable: Bool) -> AnyPublisher<[Item], ItemsServiceError>

    func fetchQuery() -> AnyPublisher<ResponceType, ItemsServiceError>
    func searchQuery(_ text: String) -> AnyPublisher<ResponceType, ItemsServiceError>
    func nextQuery() -> AnyPublisher<ResponceType, ItemsServiceError>

    func fetchItem(_ id: UUID) -> AnyPublisher<Item, ItemsServiceError>
}

var ItemsServiceQueryLimit: Int { 30 }

struct ItemsServiceCursor {
    let snapshot: QueryDocumentSnapshot?
    let count: Int

    var date: Date? {
        guard let dateFromSnapshot = snapshot?.data()["createdAt"] as? UInt64 else { return nil }
        return Date(
            timeIntervalSince1970:
                TimeInterval(bitPattern: dateFromSnapshot)
        )
    }
}


extension ItemsServiceType {
    func nextQuery() -> AnyPublisher<ResponceType, ItemsServiceError> {
        fetchQuery()
    }

    func fetchItemsFromQuery(_ query: Query, isPaginatable: Bool = false) -> AnyPublisher<[Item], ItemsServiceError> {
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
                                    description: data["description"] as? String ?? "",
                                    iconUrl: data["icon"] as? String ?? "",
                                    originalUrl: data["link"] as? String ?? "",
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
