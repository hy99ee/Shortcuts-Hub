import Combine
import Foundation

protocol UserItemsServiceType: ItemsServiceType {
    func requestItemFromAppleApi(appleId id: String) -> AnyPublisher<AppleApiItem, ItemsServiceError>
    func uploadNewItem(_ item: Item) -> AnyPublisher<Item, ItemsServiceError>
    func removeItem(_ item: Item) -> AnyPublisher<Item, ItemsServiceError>
}
