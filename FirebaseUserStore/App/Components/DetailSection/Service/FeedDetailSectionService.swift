import Combine
import SwiftUDF
import Firebase
import FirebaseDatabase

protocol FeedDetailSectionServiceType: EnvironmentType {
}

final class FeedDetailSectionService: FeedDetailSectionServiceType {
    typealias ServiceError = ItemsServiceError
    typealias ResponceType = FetchedResponce

    let db = Firestore.firestore()
    static let collectionName = "Items"

    func fetchItemsFromQuery(_ query: Query, isPaginatable: Bool = false) -> AnyPublisher<[Item], ItemsServiceError> {
        Deferred {
            Future { promise in
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
                                    icon: data["icon"] as? Data ?? Data(),
                                    originalUrl: data["original_link"] as? String ?? "",
                                    validateByAdmin: data["validation"] as? Int ?? 0,
                                    createdAt: Date(timeIntervalSince1970: TimeInterval(bitPattern: (data["createdAt"] as? UInt64 ?? 0)))
                                    
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

    func fetchQuery(from section: IdsSection) -> AnyPublisher<FetchedResponce, ItemsServiceError> {
        Deferred {
            Future {[weak self] promise in
                guard let self else { return promise(.failure(.unknownError))}
//                guard let user = self.user else { return promise(.failure(ServiceError.unauth)) }

                let collection = self.db.collection(Self.collectionName)
                let query = collection
                    .whereField("id", in: section.itemsIds)
                    .limit(to: ItemsServiceQueryLimit)

//                if let last = self.itemsServiceCursor?.snapshot {
//                    query = query.start(afterDocument: last)
//                }

                let countQuery = query.count

                countQuery.getAggregation(source: .server) { snapshot, error in
                    guard let snapshot else { return promise(.failure( error != nil ? ServiceError.firebaseError(error!) : ServiceError.unknownError)) }
                    return promise(.success(FetchedResponce(query: query, count: Int(truncating: snapshot.count))))
                }
                
            }
        }.eraseToAnyPublisher()
    }
}
