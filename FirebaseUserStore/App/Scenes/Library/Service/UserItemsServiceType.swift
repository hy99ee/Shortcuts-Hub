import Combine
import Foundation

protocol UserItemsServiceType: ItemsServiceType, DetainedServiceType where DetainedRequestType == LibraryDetainedRequest {
    func requestItemFromAppleApi(appleId id: String) -> AnyPublisher<AppleApiItem, ItemsServiceError>
    func uploadNewItem(_ item: Item) -> AnyPublisher<Item, ItemsServiceError>
    func removeItem(_ item: Item) -> AnyPublisher<Item, ItemsServiceError>
}

enum LibraryDetainedRequest: RequestWithRepeatDelay {
    case initLibrary
    case updateLibrary

    var repeatDelaySeconds: Double {
        switch self {
        case .initLibrary:
            return 13
        case .updateLibrary:
            return 5
        }
    }
}
