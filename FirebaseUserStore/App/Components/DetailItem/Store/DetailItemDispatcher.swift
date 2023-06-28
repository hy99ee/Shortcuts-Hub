import Foundation
import Combine
import SwiftUDF

let feedDetailItemDispatcher: DispatcherType<DetailItemAction, DetailItemMutation, DetailItemPackages> = { action, packages in
    switch action {
    case .addToSaved, .removeFromSaved:
        return Just(DetailItemMutation.break).eraseToAnyPublisher()
        
    case let .itemByOperation(item, operation):
        return mutationItemByOperation(item: item, operation: operation, packages)
            .withStatus(start: .progressViewStatus(status: .start), finish: .progressViewStatus(status: .stop))
            .eraseToAnyPublisher()
    }

    // MARK: - Mutations
    func mutationItemByOperation(item: Item, operation: DetailItemStore.Operation, _ packages: DetailItemPackages) -> AnyPublisher<DetailItemMutation, Never> {
        switch operation {
        case .saved:
            return itemAddToSaved(item: item, packages).delay(for: .milliseconds(500), scheduler: DispatchQueue.main).eraseToAnyPublisher()
        case .unsaved:
            return itemRemoveFromSaved(item: item, packages).delay(for: .milliseconds(500), scheduler: DispatchQueue.main).eraseToAnyPublisher()
        }
    }

    func itemAddToSaved(item: Item, _ packages: DetailItemPackages) -> AnyPublisher<DetailItemMutation, Never> {
        packages.sessionService.updateDatabaseUser(with: .add(item: item))
            .map { _ in .itemsSavedStatusChanged(with: .saved) }
            .catch { Just(.error(with: .unsaved, error: $0)) }
            .eraseToAnyPublisher()
    }
    
    func itemRemoveFromSaved(item: Item, _ packages: DetailItemPackages) -> AnyPublisher<DetailItemMutation, Never> {
        packages.sessionService.updateDatabaseUser(with: .remove(item: item))
            .map { _ in .itemsSavedStatusChanged(with: .unsaved) }
            .catch { Just(.error(with: .saved, error: $0)) }
            .eraseToAnyPublisher()
    }
}

