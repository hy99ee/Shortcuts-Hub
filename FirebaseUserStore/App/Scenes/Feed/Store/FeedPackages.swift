import Combine
import FirebaseAuth

protocol FeedPackagesType: EnvironmentPackages {
    associatedtype PackageItemsService: ItemsServiceType

    var itemsService: PackageItemsService! { get }

//    func getFeedSectionDetailStore(_ section: IdsSection) -> FeedDetailSectionStore
}


class FeedPackages: FeedPackagesType {
    private(set) var itemsService: FeedItemsService!

//    private lazy var feedSectionDetailStore = FeedDetailSectionStore(
//        state: FeedDetailSectionState(),
//        dispatcher: feedFeedDetailSectionSectionDispatcher,
//        reducer: feedDetailSectionReducer,
//        packages: FeedDetailSectionPackages()
//    )

    func makeFeedSectionDetailStore(_ section: IdsSection) -> FeedDetailSectionStore {
        FeedDetailSectionStore(
            state: FeedDetailSectionState(section: section),
            dispatcher: feedFeedDetailSectionSectionDispatcher,
            reducer: feedDetailSectionReducer,
            packages: FeedDetailSectionPackages()
        )
    }

    init() {
        itemsService = _itemsService
    }

    func reinit() -> Self {
        self.itemsService = _itemsService

        return self
    }

    private var _itemsService: PackageItemsService {
        FeedItemsService()
    }
}

class _FeedPackages: FeedPackagesType, Unreinitable {
    lazy var itemsService: MockFeedItemsService! = MockFeedItemsService()
}
