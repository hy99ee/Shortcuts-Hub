import Combine
import Firebase
import FirebaseFirestore

final class UserItemsService: UserItemsServiceType {
    typealias ServiceError = ItemsServiceError
    typealias ResponceType = FetchedResponce

    private let db = Firestore.firestore()
    private static let collectionName = "Items"

    let userId: String?

    init(userId: String?) {
        self.userId = userId
    }

    func fetchItems(_ query: Query, filter: @escaping (Item) -> Bool = { _ in true }) -> AnyPublisher<[Item], ItemsServiceError> {
        Deferred {
            Future { promise in
                query.getDocuments { snapshot, error in
                    if let _error = error {
                        return promise(.failure(.firebaseError(_error)))
                    }
                    if let snapshot = snapshot {
                        var items: [Item] = []
                        for document in snapshot.documents {
                            let data = document.data()

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
                        return promise(.success(items.filter(filter)))
                    }
                }
            }
        }
        .delay(for: .milliseconds(250), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchQuery() -> AnyPublisher<FetchedResponce, ItemsServiceError> {
        Deferred {
            Future { promise in
                Task { [weak self] in
                    guard let self else { return promise(.failure(ServiceError.invalidUserId)) }
                    guard let userId = self.userId else { return promise(.failure(ServiceError.unauth)) }

                    let collection = self.db.collection(Self.collectionName)
                    let query = collection.whereField("userId", isEqualTo: userId)
                    let countQuery = query.count

                    countQuery.getAggregation(source: .server) { snapshot, error in
                        guard let snapshot else { return promise(.failure( error != nil ? ServiceError.firebaseError(error!) : ServiceError.unknownError)) }
                        return promise(.success(FetchedResponce(query: query, count: Int(truncating: snapshot.count))))
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
                guard let userId = self.userId else { return promise(.failure(ServiceError.unauth)) }

                let collection = self.db.collection(Self.collectionName)
                let query = collection.whereField("userId", isEqualTo: userId)
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
                guard let self else { return promise(.failure(.unknownError)) }
                guard let userId = self.userId else { return promise(.failure(ServiceError.unauth)) }

                let ref = self.db.collection(Self.collectionName)
                    .whereField("id", isEqualTo: id.uuidString)
                    .whereField("userId", isEqualTo: userId)
                
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

    func uploadNewItem(_ item: Item) -> AnyPublisher<UUID, ItemsServiceError> {
        Deferred {
            Future {[weak self] promise in
                guard let self else { return promise(.failure(.invalidUserId)) }
                guard let userId = self.userId else { return promise(.failure(ServiceError.unauth)) }

                let document = [
                    "id": UUID().uuidString,
                    "userId": userId,
                    "title": item.title,
                    "icon": item.iconUrl?.absoluteString ?? "",
                    "description": item.description
                ]
                self.db.collection(Self.collectionName).addDocument(data: document) { error in
                    if let error = error {
                        promise(.failure(.firebaseError(error)))
                    }
                }
                guard
                    let id = document["id"],
                    let documentID = UUID(uuidString: id)
                else {
                    return promise(.failure(.invalidUserId))
                }

                return promise(.success(documentID))
            }
        }.eraseToAnyPublisher()
    }

    func removeItem(_ id: UUID) -> AnyPublisher<UUID, ItemsServiceError> {
        Deferred {
            Future {[weak self] promise in
                guard
                    let self else { return promise(.failure(.invalidUserId)) }
                guard let userId = self.userId else { return promise(.failure(ServiceError.unauth)) }

                let ref = self.db.collection(Self.collectionName)
                    .whereField("id", isEqualTo: (id.uuidString))
                    .whereField("userId", isEqualTo: userId)
                    
                var documentID: String?
                ref.getDocuments { snapshot, error in
                    documentID = snapshot?.documents.first?.documentID

                    guard let documentID = documentID else { return promise(.failure(.deleteItem)) }

                    self.db.collection(Self.collectionName).document(documentID).delete() {
                        return promise($0 == nil ? .success(id) : .failure(.deleteItem))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
}