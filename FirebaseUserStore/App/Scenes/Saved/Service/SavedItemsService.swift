import Combine
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

final class SavedItemsService: SavedItemsServiceType {
    typealias ServiceError = ItemsServiceError
    typealias ResponceType = FetchedResponce

    let db = Firestore.firestore()
    static let collectionName = "Items"
    private(set) var itemsServiceCursor: ItemsServiceCursor?
    private let appleApiPath = "https://www.icloud.com/shortcuts/api/records/"

    let user: DatabaseUser?

    init(user: DatabaseUser?) {
        self.user = user
    }

    func fetchItemsFromQuery(_ query: Query, isPaginatable: Bool = false) -> AnyPublisher<[Item], ItemsServiceError> {
        Deferred {
            Future {[weak self] promise in
                guard let self else { return promise(.failure(.unknownError)) }

                query.getDocuments { snapshot, error in
                    if let _error = error {
                        return promise(.failure(.firebaseError(_error)))
                    }
                    guard let documents = snapshot?.documents else {
                        return promise(.failure(.unknownError))
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
                                    validateByAdmin: data["validation"] as? Int ?? 0,
                                    createdAt: Date(timeIntervalSince1970: TimeInterval(bitPattern: (data["createdAt"] as? UInt64 ?? 0)))
                                    
                                )
                            )
                        }

                    if isPaginatable {
                        if let lastDocument = documents.last {
                            self.itemsServiceCursor = .init(snapshot: lastDocument, count: documents.count)
                        } else {
                            self.itemsServiceCursor = .init(snapshot: nil, count: 0)
                        }
                    }

                    return promise(.success(items))
                    
                }
            }
        }
        .delay(for: .milliseconds(250), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchQuery() -> AnyPublisher<FetchedResponce, ItemsServiceError> {
        guard let user = self.user else { return Fail(error: ItemsServiceError.invalidUserId).eraseToAnyPublisher() }
        
        return Publishers.Sequence(sequence: user.savedIdWithLimitations)
            .flatMap { savedIds in
                Deferred {
                    Future { promise in
                        Task { [weak self] in
                            guard let self else { return promise(.failure(ServiceError.invalidUserId)) }
//                            guard let user = self.user else { return promise(.failure(ServiceError.unauth)) }
                            
                            let collection = self.db.collection(Self.collectionName)
                            let query = collection
                                .whereField("id", in: savedIds)
                            //                        .order(by: "createdAt", descending: true)
                            
                            let countQuery = query.count
                            
                            countQuery.getAggregation(source: .server) { snapshot, error in
                                guard let snapshot else {
                                    return promise(
                                        .failure(
                                            error != nil
                                            ? ServiceError.firebaseError(error!)
                                            : ServiceError.unknownError
                                        )
                                    )
                                }
                                return promise(.success(FetchedResponce(query: query, count: Int(truncating: snapshot.count))))
                            }
                        }
                    }
                }
            }
            .eraseToAnyPublisher()
    }

    func searchQuery(_ text: String) -> AnyPublisher<FetchedResponce, ItemsServiceError> {
        guard let user = self.user else { return Fail(error: ItemsServiceError.invalidUserId).eraseToAnyPublisher() }

        return Publishers.Sequence(sequence: user.savedIdWithLimitations)
            .flatMap { savedIds in
                Deferred {
                    Future {[weak self] promise in
                        guard let self else { return promise(.failure(.unknownError))}
                        
                        let collection = self.db.collection(Self.collectionName)
                        let query = collection
                            .whereField("id", in: savedIds)
                            .whereField("tags", arrayContains: text)
                        
                        return promise(.success(FetchedResponce(query: query, count: 0)))
                    }
                }
            }.eraseToAnyPublisher()
    }

    func nextQuery() -> AnyPublisher<FetchedResponce, ItemsServiceError> {
        Deferred {
            Future {[weak self] promise in
                guard let self else { return promise(.failure(.unknownError))}
                guard let user = self.user else { return promise(.failure(ServiceError.unauth)) }

                let collection = self.db.collection(Self.collectionName)
                var query = collection
                    .whereField("id", in: user.savedIds)
                    .limit(to: ItemsServiceQueryLimit)

                if let last = self.itemsServiceCursor?.snapshot {
                    query = query.start(afterDocument: last)
                }

                let countQuery = query.count

                countQuery.getAggregation(source: .server) { snapshot, error in
                    guard let snapshot else { return promise(.failure( error != nil ? ServiceError.firebaseError(error!) : ServiceError.unknownError)) }
                    return promise(.success(FetchedResponce(query: query, count: Int(truncating: snapshot.count))))
                }
                
            }
        }.eraseToAnyPublisher()
    }

    func fetchItem(_ id: UUID) -> AnyPublisher<Item, ItemsServiceError> {
        Deferred {
            Future {[weak self] promise in
                guard let self else { return promise(.failure(.unknownError)) }
                guard self.user != nil else { return promise(.failure(ServiceError.unauth)) }

                let query = self.db.collection(Self.collectionName)
                    .whereField("id", isEqualTo: id.uuidString)

                query.getDocuments { snapshot, error in
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
                                description: data["description"] as? String ?? "",
                                iconUrl: data["icon"] as? String ?? "",
                                originalUrl: data["link"] as? String ?? "",
                                validateByAdmin: data["validation"] as? Int ?? 0,
                                createdAt: Date(timeIntervalSince1970: TimeInterval(bitPattern: (data["createdAt"] as? UInt64 ?? 0)))
                            )
                        }
                        return promise(item != nil ? .success(item!) : .failure(.none))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
}