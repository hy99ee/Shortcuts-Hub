import Combine
import FirebaseAuth

protocol LibraryPackagesType: EnvironmentPackages {
    associatedtype PackageItemsService: ItemsServiceType

    var itemsService: PackageItemsService! { get }
    var loginStore: LoginStore { get }
}

class _LibraryPackages: LibraryPackagesType {
    private(set) var itemsService: UserItemsService!

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
        UserItemsService(userId: Auth.auth().currentUser?.uid)
    }
}

class LibraryPackages: LibraryPackagesType, Unreinitable {
    lazy var loginStore = LoginStore(
        state: LoginState(),
        dispatcher: loginDispatcher,
        reducer: loginReducer,
        packages: LoginPackages()
    )

    lazy var itemsService: MockLibraryService! = MockLibraryService()
}
