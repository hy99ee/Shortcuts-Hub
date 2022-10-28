import Combine
import Foundation

protocol ItemsServiceType: EnvironmentType {
    associatedtype ServiceError: Error
    func fetchDishesByUserRequest() -> AnyPublisher<[Item], ServiceError>
    func fetchItemByID(_ id: UUID) -> AnyPublisher<Item, ServiceError>

    func setNewItemRequest() -> AnyPublisher<UUID, ServiceError>
    func removeItemRequest(_ id: UUID) -> AnyPublisher<UUID, ServiceError>
}
