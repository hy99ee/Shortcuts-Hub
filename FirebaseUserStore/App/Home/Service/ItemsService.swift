
import Combine
import Firebase

protocol ItemsServiceType {
    func fetchDishesByUserRequest() -> AnyPublisher<[Item], ItemsSerciveError>
    func fetchItemByID(_ id: UUID) -> AnyPublisher<Item, ItemsSerciveError>

    func setNewItemRequest() -> AnyPublisher<UUID, ItemsSerciveError>
}

enum ItemsSerciveError: Error {
    case invalidUserId
    case writeNewItemFailure

    case firebaseError(_ error: Error)
    
    case unknownError
}

final class ItemsService: ItemsServiceType {
    private let db = Firestore.firestore()
    let userId = Auth.auth().currentUser?.uid
    var idInc = 0

    func fetchDishesByUserRequest() -> AnyPublisher<[Item], ItemsSerciveError> {
        Deferred {
            Future {[weak self] promise in
                
                guard let self = self,
                    let userId = self.userId else { return promise(.failure(.invalidUserId)) }
                
                let ref = self.db.collection("Items").whereField("userId", isEqualTo: userId)
                
                ref.getDocuments { snapshot, error in
                    if let _error = error {
                        return promise(.failure(.firebaseError(_error)))
                    }

                    if let snapshot = snapshot {
                        var items:[Item] = []
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
    
    func fetchItemByID(_ id: UUID) -> AnyPublisher<Item, ItemsSerciveError> {
        Deferred {
            Future {[weak self] promise in
                
                guard let self = self,
                      let userId = self.userId
                else { return promise(.failure(.unknownError))}

                let ref = self.db.collection("Items")
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
    
    func setNewItemRequest() -> AnyPublisher<UUID, ItemsSerciveError> {
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
                self.db.collection("Items").addDocument(data: document) { error in
                    if let error = error {
                        promise(.failure(.firebaseError(error)))
                    }
                }
                guard let documentID = UUID(uuidString: document["id"] ?? "") else { return promise(.failure(.invalidUserId)) }
                return promise(.success(documentID))
            }
        }.eraseToAnyPublisher()
    }
}
