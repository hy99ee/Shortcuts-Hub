import Combine
import FirebaseAuth

protocol FeedPackagesType: EnvironmentPackages {
    associatedtype PackageItemsService: ItemsServiceType

    var itemsService: PackageItemsService! { get }
    var loginStore: LoginStore { get }
}


class _FeedPackages: FeedPackagesType {
    private(set) var itemsService: PublicItemsService!
    
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

    private var _itemsService: PackageItemsService {
        PublicItemsService()
    }
}

class FeedPackages: FeedPackagesType, Unreinitable {
    lazy var loginStore = LoginStore(
        state: LoginState(),
        dispatcher: loginDispatcher,
        reducer: loginReducer,
        packages: LoginPackages()
    )

    lazy var itemsService: MockPublicItemsService! = MockPublicItemsService()
}
