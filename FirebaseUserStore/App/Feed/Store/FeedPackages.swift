import Combine
import FirebaseAuth

protocol FeedPackagesType: EnvironmentPackages {
    associatedtype PackageItemsService: ItemsServiceType

    var itemsService: PackageItemsService! { get }
    var sessionService: SessionService { get }
}
extension FeedPackagesType {
    var sessionService: SessionService { SessionService.shared }
}

class FeedPackages: FeedPackagesType {
    private(set) var itemsService: ItemsService!
    
    init() {
        itemsService = _itemsService
    }

    func reinit() -> Self {
        self.itemsService = _itemsService

        return self
    }

    private var _itemsService: ItemsService {
        if let userId = Auth.auth().currentUser?.uid {
            return UserItemsService(userId: userId)
        } else {
            return PublicItemsService()
        }
    }
}

class MockFeedPackages: FeedPackagesType, Unreinitable {
    lazy var itemsService: MockItemsService! = MockItemsService()
}
