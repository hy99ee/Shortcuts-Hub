import Combine
import SwiftUI
import Firebase

let savedDispatcher: DispatcherType<SavedAction, SavedMutation, SavedPackages> = { action, packages in
    switch action {
    case .initSaved, .updateSaved:
        return mutationFetchItems(packages: packages)
            .withStatus(
                start: .progressView(status: .start),
                finish: .progressView(status: .stop)
            )
            .merge(with: Just(.setSearchFilter("")))
            .eraseToAnyPublisher()
        
    case .initLocalSaved, .updateLocalSaved, .localSearch:
        return Just(SavedMutation.fetchedItems(newItems: mockItems)).eraseToAnyPublisher()

    case let .search(text):
        if text.isEmpty { return mutationFetchItems(packages: packages) }
        return mutationSearchItems(by: text, packages: packages)
            .withStatus(
                start: .progressView(status: .start),
                finish: .progressView(status: .stop)
            )
            .eraseToAnyPublisher()

    case .next:
        return mutationNextItems(packages: packages)
            .merge(with: Just(SavedMutation.setSearchFilter("")))
            .eraseToAnyPublisher()

    case let .click(item):
        return Just(.detail(item: item)).eraseToAnyPublisher()

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
                    itemsFromMultipleQuery.send(.fetchedItems(newItems: items.itemsByModified))
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
            .map { .fetchedNewItems($0) }
            .catch { Just(.errorAlert(error: $0)) }
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

    func mutationShowAlert(with error: Error) -> AnyPublisher<SavedMutation, Never> {
        Just(SavedMutation.errorAlert(error: error))
            .eraseToAnyPublisher()
    }
}
