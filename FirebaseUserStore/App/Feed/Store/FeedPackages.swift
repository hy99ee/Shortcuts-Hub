import Combine

class FeedPackages: EnvironmentPackages {
    typealias PackageItemsService = ItemsService

    lazy var itemsService = PackageItemsService()
    lazy var sessionService = SessionService.shared
}
