import Combine
import Firebase
import FirebaseFirestore

final class PublicItemsService: ItemsServiceType {
    typealias ServiceError = ItemsServiceError
    typealias ResponceType = FetchedResponce
    
    private let db = Firestore.firestore()
    private static let collectionName = "Items"
    
    func fetchQuery() -> AnyPublisher<FetchedResponce, ItemsServiceError> {
        Deferred {
            Future { promise in
                Task { [weak self] in
                    guard let self else { return promise(.failure(.unknownError)) }

                    let collection = self.db.collection(Self.collectionName)
                    let countQuery = collection.count

                    countQuery.getAggregation(source: .server) { snapshot, error in
                        guard let snapshot else { return promise(.failure( error != nil ? ServiceError.firebaseError(error!) : ServiceError.unknownError)) }
                        return promise(.success(FetchedResponce(query: collection, count: Int(truncating: snapshot.count))))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func searchQuery(_ text: String) -> AnyPublisher<FetchedResponce, ItemsServiceError> {
        Deferred {
            Future {[weak self] promise in
                guard let self else { return promise(.failure(.unknownError))}

                let query = self.db.collection(Self.collectionName)
                    .whereField("title", isGreaterThanOrEqualTo: text)
                    .order(by: "title")

                return promise(.success(FetchedResponce(query: query, count: 0)))
            }
        }
        .eraseToAnyPublisher()
    }

    func fetchItem(_ id: UUID) -> AnyPublisher<Item, ItemsServiceError> {
        Deferred {
            Future {[weak self] promise in
                guard let self else { return promise(.failure(.unknownError))}

                let ref = self.db.collection(Self.collectionName)
                    .whereField("id", isEqualTo: id.uuidString)
                
                ref.getDocuments { snapshot, error in
                    if let _error = error {
                        return promise(.failure(.firebaseError(_error)))
                    }

                    if let snapshot = snapshot {
                        var item: Item?
                        for document in snapshot.documents {
                            let data = document.data()

                            item = Item(
                                id: UUID(uuidString: (data["id"] as? String ?? "")) ?? UUID(),
                                userId: data["userId"] as? String ?? "",
                                title: data["title"] as? String ?? "",
                                iconUrl: URL(string: data["icon"] as? String ?? ""),
                                description: data["description"] as? String ?? "",
                                createdAt: Date()
                            )
                        }
                        return promise(item != nil ? .success(item!) : .failure(.unknownError))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
}
