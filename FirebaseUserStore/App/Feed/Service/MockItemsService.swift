import Combine
import Firebase

final class MockItemsService: ItemsServiceType {
    private let db = Firestore.firestore()
    private static let collectionName = "Items"
    
    let userId = Auth.auth().currentUser?.uid
    var idInc = 0

    func fetchDishesByUserRequest() -> AnyPublisher<[Item], ItemsServiceError> {
        Deferred {
            Future {[weak self] promise in
                
                guard let self = self,
                    let userId = self.userId else { return promise(.failure(.invalidUserId)) }
                
                let ref = self.db.collection(Self.collectionName).whereField("userId", isEqualTo: userId)
                
                ref.getDocuments { snapshot, error in
                    if let _error = error {
                        return promise(.failure(.firebaseError(_error)))
                    }

                    if let snapshot = snapshot {
                        var items: [Item] = []
                        for document in snapshot.documents {
                            let data = document.data()

                            items.append(Item(
                                id: UUID(uuidString: (data["id"] as? String ?? "")) ?? UUID(),
                                userId: data["userId"] as? String ?? "",
                                title: data["title"] as? String ?? "",
                                description: data["description"] as? String ?? "",
                                source: ""
                            ))
                        }
                        return promise(.success(items))
                    }
                
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func fetchItemByID(_ id: UUID) -> AnyPublisher<Item, ItemsServiceError> {
        Deferred {
            Future {[weak self] promise in
                
                guard let self = self,
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
                    let self = self,
                    let userId = self.userId else { return promise(.failure(.invalidUserId)) }
                self.idInc += 1
                let document = [
                    "id": UUID().uuidString,
                    "userId": userId,
                    "title": "title \(self.idInc)",
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
                    let self = self,
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
