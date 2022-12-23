import Combine

protocol FeedPackagesType: EnvironmentPackages {
    associatedtype PackageItemsService: ItemsServiceType

    var itemsService: PackageItemsService { get }
    var sessionService: SessionService { get }
}
extension FeedPackagesType {
    var sessionService: SessionService { SessionService.shared }
}

class FeedPackages: FeedPackagesType {
    lazy var itemsService = ItemsService()
}

class MockFeedPackages: FeedPackagesType {
    lazy var itemsService = MockItemsService()
}
