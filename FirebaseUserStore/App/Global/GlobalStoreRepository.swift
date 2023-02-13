import Combine
import SwiftUI

final class GlobalStoreRepository {
    static let shared = GlobalStoreRepository()
    private init() { }

    lazy var sender = GlobalSender()

    lazy var feedStore = FeedStore(
        state: FeedState(),
        dispatcher: feedDispatcher,
        reducer: feedReducer,
        packages: FeedPackages(),
        middlewares: [FeedStore.middlewareFeedLogger, FeedStore.middlewareLocalSearch]
    )

    lazy var loginStore = LoginStore(
        state: LoginState(),
        dispatcher: loginDispatcher,
        reducer: loginReducer,
        packages: LoginPackages()
    )

    lazy var libraryStore = LibraryStore(
        state: LibraryState(),
        dispatcher: libraryDispatcher,
        reducer: libraryReducer,
        packages: LibraryPackages(),
        middlewares: [LibraryStore.middlewareLocalSearch, LibraryStore.middlewareAuthCheck]
    )
}
