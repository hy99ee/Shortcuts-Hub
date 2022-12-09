import Foundation

final class StoreRepository {
    static let shared = StoreRepository()
    private init() { }

    lazy var loginStore = LoginStore(
        state: LoginState(),
        dispatcher: loginDispatcher,
        reducer: loginReducer,
        packages: LoginPackages(),
        middlewares: [LoginStore.middleware1, LoginStore.middleware1]
        )

    lazy var feedStore = FeedStore(
        state: FeedState(),
        dispatcher: feedDispatcher,
        reducer: feedReducer,
        packages: FeedPackages(),
        middlewares: [FeedStore.middleware5]
    )
}
