import Combine
import FirebaseAuth

protocol SavedPackagesType: EnvironmentPackages {
    associatedtype PackageItemsService: ItemsServiceType

    var itemsService: PackageItemsService! { get }
}

class SavedPackages: SavedPackagesType {
    private(set) var itemsService: SavedItemsService!
    private var subscriptions = Set<AnyCancellable>()

    init() {
        itemsService = _itemsService

        sessionService.$userDetails
            .compactMap { $0 }
            .removeDuplicates()
            .sink { [unowned self]  in
                self.itemsService = SavedItemsService(user: $0.value)
            }
            .store(in: &subscriptions)
    }

    func reinit() -> Self {
        self.itemsService = _itemsService

        return self
    }

    private var _itemsService: PackageItemsService {
        SavedItemsService(user: sessionService.userDetails?.value)
    }
}

class _SavedPackages: SavedPackagesType, Unreinitable {
    lazy var itemsService: MockSavedService! = MockSavedService()
}
