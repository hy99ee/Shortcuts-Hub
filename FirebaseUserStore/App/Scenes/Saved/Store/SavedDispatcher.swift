import Combine
import SwiftUI
import Firebase

let savedDispatcher: DispatcherType<SavedAction, SavedMutation, SavedPackages> = { action, packages in
    switch action {
    case .initSaved, .updateSaved:
        return mutationFetchItems(packages: packages)
            .merge(with: Just(.setSearchFilter("")))
            .eraseToAnyPublisher()

    case let .search(text):
        if text.isEmpty { return mutationFetchItems(packages: packages) }
        return mutationSearchItems(by: text, packages: packages)
            .withStatus(start: .progressView(status: .start), finish: .progressView(status: .stop))
            .eraseToAnyPublisher()

    case .next:
        return mutationNextItems(packages: packages)
            .merge(with: Just(SavedMutation.setSearchFilter("")))
            .eraseToAnyPublisher()

    case let .click(item):
        return Just(.detail(item: item)).eraseToAnyPublisher()

    case let .updateItem(id):
        return mutationFetchItem(by: id, packages: packages)
    
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
        let fetchDocs = Publishers.Zip(
            Just(Date.now)
                .setFailureType(to: ItemsServiceError.self),
            packages.itemsService.fetchQuery()
                .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
        )
        .share()

        let fetchFromDocs = fetchDocs
            .map { $0.1.query }
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .flatMap { packages.itemsService.fetchItemsFromQuery($0) }
        
        return Publishers.Merge(
            fetchDocs
                .map { (date, docs) in
                    let timeSpent = Date.now.timeIntervalSinceReferenceDate - date.timeIntervalSinceReferenceDate
                    if timeSpent < 1 { return .fastUpdate }

                    if docs.count > 0 {
                        return .updateItemsPreloaders(count: docs.count)
                    } else {
                        return .fastUpdate
                    }
                }
                .catch { Just(.errorAlert(error: $0)) }
                .eraseToAnyPublisher()
                .withStatus(start: .progressView(status: .start), finish: .progressView(status: .stop))
            , fetchFromDocs
                .delay(for: .seconds(1), scheduler: DispatchQueue.main)
                .map { .fetchedItems(newItems: $0) }
                .catch { Just(.errorAlert(error: $0)) }
        )
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
    func mutationFetchItem(by id: UUID, packages: SavedPackages) -> AnyPublisher<SavedMutation, Never> {
        packages.itemsService.fetchItem(id)
            .flatMap { item in
                packages.sessionService.updateDatabaseUser(with: .addIds(id.uuidString))
                    .mapError { _ in ItemsServiceError.userDatabaseError }
                    .map { _ in item }
            }
            .map { .newItem(item: $0) }
            .catch { Just(.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }
    func mutationSearchItems(by text: String, packages: SavedPackages) -> AnyPublisher<SavedMutation, Never> {
        let fetchDocs = packages.itemsService.searchQuery(text.lowercased())

        let fetchFromDocs = fetchDocs
            .flatMap { packages.itemsService.fetchItemsFromQuery($0.query, isPaginatable: false) }

        return fetchFromDocs
            .map { SavedMutation.searchItems($0) }
            .catch { Just(.errorAlert(error: $0)) }
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func mutationShowAlert(with error: Error) -> AnyPublisher<SavedMutation, Never> {
        Just(SavedMutation.errorAlert(error: error))
            .eraseToAnyPublisher()
    }
}
