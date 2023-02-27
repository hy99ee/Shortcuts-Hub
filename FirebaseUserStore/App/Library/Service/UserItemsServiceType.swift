import Combine
import Foundation

protocol UserItemsServiceType: ItemsServiceType {
    func uploadNewItem(_ item: Item) -> AnyPublisher<UUID, ItemsServiceError>
    func removeItem(_ id: UUID) -> AnyPublisher<UUID, ItemsServiceError>
}
