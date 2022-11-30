import Foundation

class FeedPackages: EnvironmentPackages {
    typealias PackageItemsService = ItemsService

    lazy var itemsService = PackageItemsService()
}
