import Combine
import FirebaseAuth

protocol FeedPackagesType: EnvironmentPackages {
    associatedtype PackageItemsService: ItemsServiceType

    var sessionService: SessionService { get }

    var itemsService: PackageItemsService! { get }
    var loginStore: LoginStore { get }
}
extension FeedPackagesType {
    var sessionService: SessionService { SessionService.shared }
}

class FeedPackages: FeedPackagesType {
    private(set) var itemsService: ItemsService!
    
    lazy var loginStore = LoginStore(
        state: LoginState(),
        dispatcher: loginDispatcher,
        reducer: loginReducer,
        packages: LoginPackages()
    )


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
    lazy var loginStore = LoginStore(
        state: LoginState(),
        dispatcher: loginDispatcher,
        reducer: loginReducer,
        packages: LoginPackages()
    )

    lazy var itemsService: MockItemsService! = MockItemsService()
}
