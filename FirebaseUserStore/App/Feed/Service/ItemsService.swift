import Combine
import Firebase
import FirebaseFirestore

final class ItemsService: ItemsServiceType {
    typealias ServiceError = ItemsServiceError

    private let db = Firestore.firestore()
    private static let collectionName = "Items"

    let userId = Auth.auth().currentUser?.uid
    var idInc = 0

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
                                    description: data["description"] as? String ?? "",
                                    source: ""
                                )
                            )
                        }
                        return promise(.success(items.filter(filter)))
                    }
                }
            }
        }
        .delay(for: .seconds(3), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchQuery() -> AnyPublisher<FetchedResponce, ItemsServiceError> {
        Deferred {
            Future { promise in
                Task { [weak self] in
                    guard let self,
                          let userId = self.userId else { return promise(.failure(ServiceError.invalidUserId)) }

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
        .delay(for: .seconds(3), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func searchQuery(_ text: String) -> AnyPublisher<FetchedResponce, ItemsServiceError> {
        Deferred {
            Future {[weak self] promise in
                guard let self,
                      let userId = self.userId
                else { return promise(.failure(.unknownError))}

//                let localArray = Array(local).map { $0.uuidString }
//                let localSearch = [text].reduce(into: [String]()) { partialResult, element in
//                    Array(element).reduce(into: String()) {
//                        $0.append($1)
//                        partialResult.append($0)
//                    }
//                }
//                

                let collection = self.db.collection(Self.collectionName)
                let query = collection.whereField("userId", isEqualTo: userId)
                    .whereField("title", isGreaterThanOrEqualTo: text)
                    .order(by: "title")
//                    .whereField("title", isEqualTo: text)
            
//                    .whereField("title", in: [text, text.lowercased(), text.uppercased(), text.capitalized, text.capitalizedSentence])

//                if !localSearch.isEmpty {
//                    for textSearch in localSearch.suffix(2) {
//                        query.whereField("title", isEqualTo: text)
//                    }
//                }
//                if !localArray.isEmpty {
//                    for localId in localArray {
//                        query.whereField("id", isNotEqualTo: localId)
//                    }
//                }
                return promise(.success(FetchedResponce(query: query, count: 0)))

//                let countQuery = query.count
//
//                countQuery.getAggregation(source: .server) { snapshot, error in
//                    guard let snapshot else { return promise(.failure( error != nil ? ServiceError.firebaseError(error!) : ServiceError.unknownError)) }
//                    let count = Int(truncating: snapshot.count)
//                    return promise(.success(FetchedResponce(query: query, count: count)))
//                }
            }
        }
        .delay(for: .seconds(3), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchItem(_ id: UUID) -> AnyPublisher<Item, ItemsServiceError> {
        Deferred {
            Future {[weak self] promise in
                guard let self,
                      let userId = self.userId
                else { return promise(.failure(.unknownError))}

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
                                description: data["description"] as? String ?? "",
                                source: ""
                            )
                        }
                        return promise(item != nil ? .success(item!) : .failure(.unknownError))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }

    func setNewItemRequest() -> AnyPublisher<UUID, ItemsServiceError> {
        Deferred {
            Future {[weak self] promise in
                guard
                    let self,
                    let userId = self.userId else { return promise(.failure(.invalidUserId)) }
                let document = [
                    "id": UUID().uuidString,
                    "userId": userId,
                    "title": "ooo",
                    "description": "description"
                ]
                self.db.collection(Self.collectionName).addDocument(data: document) { error in
                    if let error = error {
                        promise(.failure(.firebaseError(error)))
                    }
                }
                guard let documentID = UUID(uuidString: document["id"] ?? "") else { return promise(.failure(.invalidUserId)) }
                return promise(.success(documentID))
            }
        }.eraseToAnyPublisher()
    }

    func removeItemRequest(_ id: UUID) -> AnyPublisher<UUID, ItemsServiceError> {
        Deferred {
            Future {[weak self] promise in
                guard
                    let self,
                    let userId = self.userId else { return promise(.failure(.invalidUserId)) }

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
