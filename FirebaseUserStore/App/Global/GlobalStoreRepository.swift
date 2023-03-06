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
        middlewares: [FeedStore.middlewareFeedLogger]
    )

    lazy var loginStore = LoginStore(
        state: LoginState(),
        dispatcher: loginDispatcher,
        reducer: loginReducer,
        packages: LoginPackages()
    )

    private lazy var libraryPackages = LibraryPackages()

    lazy var libraryStore = LibraryStore(
        state: LibraryState(),
        dispatcher: libraryDispatcher,
        reducer: libraryReducer,
        packages: libraryPackages,
        middlewares: [LibraryStore.middlewareAuthCheck, LibraryStore.middlewareSearchCheck]
    )

    lazy var createStore = CreateStore(
        state: CreateState(),
        dispatcher: createDispatcher,
        reducer: createReducer,
        packages: libraryPackages
    )
}
