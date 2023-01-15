import Combine
import SwiftUI

final class GlobalStoreRepository {
    private var subscriptions = Set<AnyCancellable>()
    static let shared = GlobalStoreRepository()
    private init() { }

    lazy var sender = GlobalSender()

    lazy var loginState = LoginTransitionState(sender: loginStore)

    lazy var loginStore = LoginStore(
        state: LoginState(),
        dispatcher: loginDispatcher,
        reducer: loginReducer,
        packages: LoginPackages()
    )

    lazy var feedStore = FeedStore(
        state: FeedState(),
        dispatcher: feedDispatcher,
        reducer: feedReducer,
        packages: FeedPackages(),
        middlewares: [FeedStore.middlewareLocalSearch]
    )
}
