import SwiftUI
import Firebase
import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    @Published var items: [Item] = []
    let service: ItemsServiceType
    
    private var subscription: AnyCancellable?

    init(with service: ItemsServiceType) {
        self.service = service
        fetchItems()
    }
    
    func fetchItems() {
        service.fetchDishesByUserRequest()
            .assertNoFailure()
            .assign(to: &$items)
    }
    
    func setNewItem() {
        service.setNewItemRequest()
            .flatMap {[unowned self] in service.fetchItemByID($0) }
            .map {[unowned self] in items.append($0); return items }
            .assertNoFailure()
            .assign(to: &$items)
    }
}


