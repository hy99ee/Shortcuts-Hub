import Combine
import Firebase
import FirebaseFirestore

protocol ItemsServiceType {
    associatedtype ServiceError: Error
    associatedtype ResponseType: FetchedResponseType
    associatedtype OutputType: Identifiable

    func fetchItemsFromQuery(_ query: ResponseType.DataType, isPaginatable: Bool) -> AnyPublisher<[OutputType], ItemsServiceError>

    func fetchQuery() -> AnyPublisher<ResponseType, ItemsServiceError>
    func searchQuery(_ text: String) -> AnyPublisher<ResponseType, ItemsServiceError>
    func nextQuery() -> AnyPublisher<ResponseType, ItemsServiceError>

    func fetchItem(_ id: UUID) -> AnyPublisher<Item, ItemsServiceError>
}

let ItemsServiceQueryLimit = 30

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
    func nextQuery() -> AnyPublisher<ResponseType, ItemsServiceError> {
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
                                    icon: data["icon"] as? Data ?? Data(),
                                    originalUrl: data["original_link"] as? String ?? "",
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
