import Combine
import SwiftUI
import Firebase

let savedDispatcher: DispatcherType<SavedAction, SavedMutation, SavedPackages> = { action, packages in
    switch action {
    case .initSaved, .updateSaved, .initLocalSaved, .updateLocalSaved:
        return mutationFetchItems(packages: packages)
            .withStatus(
                start: .progressView(status: .start),
                finish: .progressView(status: .stop)
            )
            .merge(with: Just(.setSearchFilter("")))
            .eraseToAnyPublisher()
        
//    case .initLocalSaved, .updateLocalSaved:
//        return Just(SavedMutation.updateItems(packages.database)).eraseToAnyPublisher()

    case .search(let text), .localSearch(let text):
        if text.isEmpty { return mutationFetchItems(packages: packages) }
        return mutationSearchItems(by: text, packages: packages)
            .withStatus(
                start: .progressView(status: .start),
                finish: .progressView(status: .stop)
            )
            .eraseToAnyPublisher()

//    case let .localSearch(text):
//        if text.isEmpty { return Just(SavedMutation.updateItems(packages.database)).eraseToAnyPublisher() }
//        return Just(SavedMutation.updateItems(packages.database.filter { $0.tags.contains(text) })).eraseToAnyPublisher()

    case .next:
        return mutationNextItems(packages: packages)
            .merge(with: Just(SavedMutation.setSearchFilter("")))
            .eraseToAnyPublisher()

    case let .click(item):
        return Just(.detail(item: item)).eraseToAnyPublisher()

    case let .addToSaved(item):
        return mutationAddItemToSaved(item, packages: packages)

    case let .removeFromSaved(item):
        return mutationRemoveItemFromSaved(item, packages: packages)

    case let .addItem(item):
        return Just(.addItem(item)).eraseToAnyPublisher()

    case let .removeItem(item):
        return Just(.removeItem(item)).eraseToAnyPublisher()

    case let .changeSearchField(text):
        return Just(.setSearchFilter(text)).eraseToAnyPublisher()

    case let .showAlert(error):
        return mutationShowAlert(with: error)
    
    case .showSavedError:
        return Just(.errorSaved).eraseToAnyPublisher()

    case .mockAction:
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }


    // MARK: - Mutations
    func mutationFetchItems(packages: SavedPackages) -> AnyPublisher<SavedMutation, Never> {
        var items = [Item]()
        let itemsFromMultipleQuery = PassthroughSubject<SavedMutation, Never>()

        packages.itemsService.fetchQuery()
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .map { $0.query }
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .flatMap { packages.itemsService.fetchItemsFromQuery($0) }
            .sink(receiveCompletion: {
                switch $0 {
                case let .failure(error):
                    itemsFromMultipleQuery.send(.errorAlert(error: error))

                case .finished:
                    itemsFromMultipleQuery.send(.updateItems(items.itemsByModified))
                }
            }, receiveValue: {
                items.append(contentsOf: $0)
            })
            .store(in: &packages.subscriptions)

        return itemsFromMultipleQuery
            .eraseToAnyPublisher()
    }

    func mutationNextItems(packages: SavedPackages) -> AnyPublisher<SavedMutation, Never> {
        guard let lastCount = packages.itemsService.itemsServiceCursor?.count, lastCount > 0 else {
            return Empty().eraseToAnyPublisher()
        }

        let fetchDocs = packages.itemsService.nextQuery()

        let fetchFromDocs = fetchDocs
            .flatMap { packages.itemsService.fetchItemsFromQuery($0.query) }

        return fetchFromDocs
            .map { SavedMutation.appendItems($0) }
            .catch { Just(SavedMutation.errorAlert(error: $0)) }
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func mutationSearchItems(by text: String, packages: SavedPackages) -> AnyPublisher<SavedMutation, Never> {
        var items = [Item]()
        let itemsFromMultipleQuery = PassthroughSubject<SavedMutation, Never>()

        packages.itemsService.searchQuery(text.lowercased())
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .map { $0.query }
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .flatMap { packages.itemsService.fetchItemsFromQuery($0) }
            .sink(receiveCompletion: {
                switch $0 {
                case let .failure(error):
                    itemsFromMultipleQuery.send(.errorAlert(error: error))

                case .finished:
                    itemsFromMultipleQuery.send(.searchItems(items.itemsByModified))
                }
            }, receiveValue: {
                items.append(contentsOf: $0)
            })
            .store(in: &packages.subscriptions)

        return itemsFromMultipleQuery
            .eraseToAnyPublisher()
    }

    func mutationAddItemToSaved(_ item: Item, packages: SavedPackages) -> AnyPublisher<SavedMutation, Never>  {
        packages.sessionService.updateDatabaseUser(with: .add(item: item))
            .map { SavedMutation.addItem(item) }
            .catch { Just(SavedMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }

    func mutationRemoveItemFromSaved(_ item: Item, packages: SavedPackages) -> AnyPublisher<SavedMutation, Never>  {
        packages.sessionService.updateDatabaseUser(with: .remove(item: item))
            .map { SavedMutation.removeItem(item) }
            .catch { Just(SavedMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }

    func mutationShowAlert(with error: Error) -> AnyPublisher<SavedMutation, Never> {
        Just(SavedMutation.errorAlert(error: error))
            .eraseToAnyPublisher()
    }
}
