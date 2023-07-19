import Combine
import Firebase
import FirebaseFirestore

final class FeedItemsService: ItemsServiceType {
    typealias ServiceError = ItemsServiceError
    typealias ResponceType = FetchedResponce
    
    private let db = Firestore.firestore()
    private static let collectionItemsName = "Items"
    private static let collectionSectionName = "Sections"

    func fetchSectionsFromQuery(_ query: Query, isPaginatable: Bool = false) -> AnyPublisher<[IdsSection], ItemsServiceError> {
        Deferred {
            Future { promise in
                query.getDocuments { snapshot, error in
                    if let _error = error {
                        return promise(.failure(.firebaseError(_error)))
                    }
                    guard let documents = snapshot?.documents else {
                        return promise(.failure(.unknownError))
                    }
                    var sections: [IdsSection] = []

                    documents
                        .map { $0.data() }
                        .forEach { data in
                            sections.append(
                                IdsSection(
                                    id: UUID(uuidString: (data["id"] as? String ?? "")) ?? UUID(),
                                    title: data["title"] as? String ?? "",
                                    subtitle: data["subtitle"] as? String ?? "",
                                    titleIcons: (data["title_icons"] as? [String] ?? []).compactMap { URL(string: $0) },
                                    itemsIds: data["ids"] as? [String] ?? []
                                )
                            )

                            sections.append(
                                IdsSection(
                                    id: UUID(),
                                    title: data["title"] as? String ?? "",
                                    subtitle: data["subtitle"] as? String ?? "",
                                    titleIcons: (data["title_icons"] as? [String] ?? []).compactMap { URL(string: $0) },
                                    itemsIds: data["ids"] as? [String] ?? []
                                )
                            )
                        }


                    return promise(.success(sections))
                }
            }
        }
        .delay(for: .milliseconds(250), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func fetchItemsFromSection(_ sections: IdsSection) -> AnyPublisher<FetchedResponce, ItemsServiceError> {
        Deferred {
            Future { promise in
                Task { [weak self] in
                    guard let self else { return promise(.failure(ServiceError.invalidUserId)) }

                    let collection = self.db.collection(Self.collectionItemsName)
                    let query = collection
                        .whereField("id", in: sections.itemsIds)

                    return promise(.success(FetchedResponce(query: query, count: 0)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchQuery() -> AnyPublisher<FetchedResponce, ItemsServiceError> {
        Deferred {
            Future { promise in
                Task { [weak self] in
                    guard let self else { return promise(.failure(.unknownError)) }

                    let collection = self.db.collection(Self.collectionSectionName)
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

                let query = self.db.collection(Self.collectionItemsName)
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

                let ref = self.db.collection(Self.collectionItemsName)
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
                                description: data["description"] as? String ?? "",
                                colorValue: data["color_value"] as? Int ?? 0,
                                icon: data["icon"] as? Data ?? Data(),
                                originalUrl: data["link"] as? String ?? "",
                                validateByAdmin: data["validation"] as? Int ?? 0,
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
