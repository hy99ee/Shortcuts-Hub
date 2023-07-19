import Combine
import SwiftUDF
import FirebaseAuth

protocol FeedPackagesType: EnvironmentPackagesWithSessionWithSession {
    associatedtype PackageItemsService: ItemsServiceType

    var itemsService: PackageItemsService! { get }

    func makeFeedSectionDetailStore(_ section: IdsSection) -> FeedDetailSectionStore
}


class FeedPackages: FeedPackagesType {
    private(set) var itemsService: FeedItemsService!

    func makeFeedSectionDetailStore(_ section: IdsSection) -> FeedDetailSectionStore {
        FeedDetailSectionStore(
            state: FeedDetailSectionState(section: section),
            dispatcher: feedFeedDetailSectionSectionDispatcher,
            reducer: feedDetailSectionReducer,
            packages: FeedDetailSectionPackages(),
            middlewares: [FeedDetailSectionStore.middlewareFetch]
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

    func makeFeedSectionDetailStore(_ section: IdsSection) -> FeedDetailSectionStore {
        FeedDetailSectionStore(
            state: FeedDetailSectionState(section: section),
            dispatcher: feedFeedDetailSectionSectionDispatcher,
            reducer: feedDetailSectionReducer,
            packages: FeedDetailSectionPackages(),
            middlewares: [FeedDetailSectionStore.middlewareFetch]
        )
    }
}
