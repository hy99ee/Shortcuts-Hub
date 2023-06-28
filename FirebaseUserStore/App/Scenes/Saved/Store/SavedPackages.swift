import Combine
import SwiftUDF
import FirebaseAuth

protocol SavedPackagesType: EnvironmentPackagesWithSessionWithSession, Unreinitable {
    associatedtype PackageItemsService: ItemsServiceType

    var itemsService: PackageItemsService! { get }
}

class SavedPackages: SavedPackagesType {
    private(set) var itemsService: SavedItemsService!
    var subscriptions = Set<AnyCancellable>()

    init() {
        sessionService.$userDetails
            .removeDuplicates()
            .sink { [unowned self] in
                self.itemsService = SavedItemsService(savedIds: $0.savedIds)
            }
            .store(in: &subscriptions)
    }
}

class _SavedPackages: SavedPackagesType {
    lazy var itemsService: MockSavedService! = MockSavedService()
}
