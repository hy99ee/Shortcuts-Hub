import Combine
import Foundation

protocol UserItemsServiceType: ItemsServiceType {
    func setNewItemRequest() -> AnyPublisher<UUID, ItemsServiceError>
    func removeItemRequest(_ id: UUID) -> AnyPublisher<UUID, ItemsServiceError>
}
