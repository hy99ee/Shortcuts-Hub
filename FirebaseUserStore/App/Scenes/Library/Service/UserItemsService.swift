import Combine
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

final class UserItemsService: UserItemsServiceType {
    typealias ServiceError = ItemsServiceError
    typealias ResponceType = FetchedResponce

    let db = Firestore.firestore()
    static let collectionName = "Items"
    private(set) var itemsServiceCursor: ItemsServiceCursor?
    private let appleApiPath = "https://www.icloud.com/shortcuts/api/records/"

    let userId: String?

    init(userId: String?) {
        self.userId = userId
    }

    func fetchItemsFromQuery(_ query: Query, isPaginatable: Bool = true) -> AnyPublisher<[Item], ItemsServiceError> {
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
                                    iconUrl: URL(string: data["icon"] as? String ?? ""),
                                    description: data["description"] as? String ?? "",
                                    validateByAdmin: ItemValidateStatus(rawValue: data["validation"] as? Int ?? 0)!,
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
        Deferred {
            Future { promise in
                Task { [weak self] in
                    guard let self else { return promise(.failure(ServiceError.invalidUserId)) }
                    guard let userId = self.userId else { return promise(.failure(ServiceError.unauth)) }

                    let collection = self.db.collection(Self.collectionName)
                    let query = collection
                        .whereField("userId", isEqualTo: userId)
                        .order(by: "createdAt", descending: true)
                        .limit(to: ItemsServiceQueryLimit)

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
        .eraseToAnyPublisher()
    }

    func searchQuery(_ text: String) -> AnyPublisher<FetchedResponce, ItemsServiceError> {
        Deferred {
            Future {[weak self] promise in
                guard let self else { return promise(.failure(.unknownError))}
                guard let userId = self.userId else { return promise(.failure(ServiceError.unauth)) }

                let collection = self.db.collection(Self.collectionName)
                let query = collection
                    .order(by: "createdAt", descending: true)
                    .whereField("userId", isEqualTo: userId)
                    .whereField("tags", arrayContains: text)

                return promise(.success(FetchedResponce(query: query, count: 0)))
            }
        }
        .eraseToAnyPublisher()
    }

    func nextQuery() -> AnyPublisher<FetchedResponce, ItemsServiceError> {
        Deferred {
            Future {[weak self] promise in
                guard let self else { return promise(.failure(.unknownError))}
                guard let userId = self.userId else { return promise(.failure(ServiceError.unauth)) }

                let collection = self.db.collection(Self.collectionName)
                var query = collection
                    .whereField("userId", isEqualTo: userId)
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
                guard let userId = self.userId else { return promise(.failure(ServiceError.unauth)) }

                let query = self.db.collection(Self.collectionName)
                    .whereField("id", isEqualTo: id.uuidString)
                    .whereField("userId", isEqualTo: userId)

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
                                iconUrl: URL(string: data["icon"] as? String ?? ""),
                                description: data["description"] as? String ?? "",
                                validateByAdmin: ItemValidateStatus(rawValue: data["validation"] as? Int ?? 0)!,
                                createdAt: Date(timeIntervalSince1970: TimeInterval(bitPattern: (data["createdAt"] as? UInt64 ?? 0)))
                            )
                        }
                        return promise(item != nil ? .success(item!) : .failure(.none))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }

    func requestItemFromAppleApi(appleId id: String) -> AnyPublisher<AppleApiItem, ItemsServiceError> {
        Deferred {
            Future {[weak self] promise in
                guard let self else { return promise(.failure(.invalidUserId)) }
                
                guard let url = URL(string: self.appleApiPath + id) else {
                    fatalError("Missing URL")
                }

                   let urlRequest = URLRequest(url: url)

                   let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                       if let error = error {
                           return promise(.failure(.appleError(error)))
                       }

                       guard let response = response as? HTTPURLResponse else {
                           return promise(.failure(.unknownError))
                       }

                       if response.statusCode == 200 {
                           guard let data = data else { return }
                           DispatchQueue.main.async {
                               do {
                                   let decodedItem = try JSONDecoder().decode(AppleApiItem.self, from: data)
                                   return promise(.success(decodedItem))
                               } catch {
                                   return promise(.failure(.unknownError))
                               }
                           }
                       }
                   }

                   dataTask.resume()
            }
        }.eraseToAnyPublisher()
    }

    
    func uploadNewItem(_ item: Item) -> AnyPublisher<UUID, ItemsServiceError> {
        Deferred {
            Future {[weak self] promise in
                guard let self else { return promise(.failure(.invalidUserId)) }
                guard let userId = self.userId else { return promise(.failure(ServiceError.unauth)) }

                let document = [
                    "id": item.id.uuidString,
                    "userId": userId,
                    "title": item.title,
                    "icon": item.iconUrl?.absoluteString ?? "",
                    "description": item.description,
                    "createdAt": item.createdAt.timeIntervalSince1970.bitPattern,
                    "modifiedAt": item.modifiedAt?.description ?? "",
                    "tags": item.tags,
                    "validation": item.validateByAdmin
                ]
                self.db.collection(Self.collectionName).addDocument(data: document) { error in
                    if let error = error {
                        promise(.failure(.firebaseError(error)))
                    }
                }

                return promise(.success(item.id))
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
