//import Combine
//import FirebaseAuth
//
//protocol CreatePackagesType: EnvironmentPackagesWithSession {
//    associatedtype PackageItemsService: ItemsServiceType
//
//    var itemsService: PackageItemsService! { get }
//    var loginStore: LoginStore { get }
//}
//
//class CreatePackages: CreatePackagesType {
//    private(set) var itemsService: UserItemsService!
//
//    lazy var loginStore = LoginStore(
//        state: LoginState(),
//        dispatcher: loginDispatcher,
//        reducer: loginReducer,
//        packages: LoginPackages()
//    )
//
//    init() {
//        itemsService = _itemsService
//    }
//
//    func reinit() -> Self {
//        self.itemsService = _itemsService
//
//        return self
//    }
//
//    private var _itemsService: PackageItemsService {
//        UserItemsService(userId: Auth.auth().currentUser?.uid)
//    }
//}
//
//class _CreatePackages: CreatePackagesType, Unreinitable {
//    lazy var loginStore = LoginStore(
//        state: LoginState(),
//        dispatcher: loginDispatcher,
//        reducer: loginReducer,
//        packages: LoginPackages()
//    )
//
//    lazy var itemsService: MockCreateService! = MockCreateService()
//}
