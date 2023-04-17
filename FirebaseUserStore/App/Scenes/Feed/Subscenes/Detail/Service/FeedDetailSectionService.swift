import Combine
import Firebase
import FirebaseDatabase

protocol FeedDetailSectionServiceType: EnvironmentType {
    func loadItems(from section: IdsSection) -> AnyPublisher<ItemsSection, FeedDetailSectionServiceError>
}

final class FeedDetailSectionService: FeedDetailSectionServiceType {
    typealias ServiceError = FeedDetailSectionServiceError
    
    func loadItems(from section: IdsSection) -> AnyPublisher<ItemsSection, FeedDetailSectionServiceError> {
        Deferred {
            Future { promise in
                
            }
        }
        .eraseToAnyPublisher()
    }
}
