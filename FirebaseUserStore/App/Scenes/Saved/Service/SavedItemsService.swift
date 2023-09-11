import Combine
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

final class SavedItemsService: SavedItemsServiceType {
    typealias ServiceError = ItemsServiceError
    typealias ResponseType = FetchedResponse

    let db = Firestore.firestore()
    static let collectionName = "Items"
    private(set) var itemsServiceCursor: ItemsServiceCursor?
    private let appleApiPath = "https://www.icloud.com/shortcuts/api/records/"

    var detainedRequests: [SavedDetainedRequest : DispatchTime] = .init()

    let savedIds: [String]

    init(savedIds: [String]) {
        self.savedIds = savedIds
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
                                    colorValue: data["color_value"] as? Int ?? 0,
                                    icon: data["icon"] as? Data ?? Data(),
                                    originalUrl: data["original_link"] as? String ?? "",
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

    func fetchQuery() -> AnyPublisher<FetchedResponse, ItemsServiceError> {
        Publishers.Sequence(sequence: savedIdsWithLimitations)
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
                                return promise(.success(FetchedResponse(query: query, count: Int(truncating: snapshot.count))))
                            }
                        }
                    }
                }
            }
            .eraseToAnyPublisher()
    }

    func searchQuery(_ text: String) -> AnyPublisher<FetchedResponse, ItemsServiceError> {
        Publishers.Sequence(sequence: savedIdsWithLimitations)
            .flatMap { savedIds in
                Deferred {
                    Future {[weak self] promise in
                        guard let self else { return promise(.failure(.unknownError))}
                        
                        let collection = self.db.collection(Self.collectionName)
                        let query = collection
                            .whereField("id", in: savedIds)
                            .whereField("tags", arrayContains: text)
                        
                        return promise(.success(FetchedResponse(query: query, count: 0)))
                    }
                }
            }.eraseToAnyPublisher()
    }

    func nextQuery() -> AnyPublisher<FetchedResponse, ItemsServiceError> {
        Deferred {
            Future {[weak self] promise in
                guard let self else { return promise(.failure(.unknownError)) }

                let collection = self.db.collection(Self.collectionName)
                var query = collection
                    .whereField("id", in: self.savedIdsWithLimitations)
                    .limit(to: ItemsServiceQueryLimit)

                if let last = self.itemsServiceCursor?.snapshot {
                    query = query.start(afterDocument: last)
                }

                let countQuery = query.count

                countQuery.getAggregation(source: .server) { snapshot, error in
                    guard let snapshot else { return promise(.failure( error != nil ? ServiceError.firebaseError(error!) : ServiceError.unknownError)) }
                    return promise(.success(FetchedResponse(query: query, count: Int(truncating: snapshot.count))))
                }
                
            }
        }.eraseToAnyPublisher()
    }

    func fetchItem(_ id: UUID) -> AnyPublisher<Item, ItemsServiceError> {
        Deferred {
            Future {[weak self] promise in
                guard let self else { return promise(.failure(.unknownError)) }

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
                                colorValue: data["color_value"] as? Int ?? 0,
                                icon: data["icon"] as? Data ?? Data(),
                                originalUrl: data["original_link"] as? String ?? "",
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

    private var savedIdsWithLimitations: [[String]] {
        savedIds.chunked(into: 9)
    }
}
