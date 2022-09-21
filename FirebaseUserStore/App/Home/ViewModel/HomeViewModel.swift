import SwiftUI
import Firebase
import Combine

final class HomeViewModel: ObservableObject, AlertProviderType {
    @Published var items: [Item] = []
    @Published var error: Error?
    
    let service: ItemsServiceType
    
    private var subscriptions: Set<AnyCancellable> = []

    init(with service: ItemsServiceType) {
        self.service = service
        fetchItems()
    }
    
    func fetchItems() {
        service.fetchDishesByUserRequest()
            .catch { error -> AnyPublisher<[Item], Never> in
                print(error.localizedDescription)
                return Just([]).eraseToAnyPublisher()
            }
            .assertNoFailure()
            .assign(to: &$items)
    }
    
    func setNewItem() {
        service.setNewItemRequest()
            .catch {[unowned self] error -> AnyPublisher<UUID, Never> in
                self.error = error
                return Empty().eraseToAnyPublisher()
            }
            .flatMap {[unowned self] in
                service.fetchItemByID($0)
                    .catch {[unowned self] error -> AnyPublisher<Item, Never> in
                        self.error = error
                        return Empty().eraseToAnyPublisher()
                    }
            }
            .sink {[unowned self] in items.append($0) }
            .store(in: &subscriptions)
    }
    
    func removeItem(_ indexSet: IndexSet) {
        let idsToDelete = indexSet.map { self.items[$0].id }
        guard let id = idsToDelete.first else { return }

        service.removeItemRequest(id)
            .catch {[unowned self] error -> AnyPublisher<UUID, Never> in
                self.error = error
                return Empty().eraseToAnyPublisher()
            }
            .sink {[unowned self] _ in self.fetchItems() }
            .store(in: &subscriptions)
    }
}


