import Combine
import SwiftUDF

let feedDispatcher: DispatcherType<FeedAction, FeedMutation, FeedPackages> = { action, packages in
    switch action {
    case .initFeed, .updateFeed:
        return mutationFetchSections(packages: packages)

    case let .click(section):
        return Just(.detail(section: section)).eraseToAnyPublisher()

    case let .addSections(sections):
        return Just(.appendSections(sections)).eraseToAnyPublisher()

    case let .changeSearchField(text):
        return Just(.setSearchFilter(text)).eraseToAnyPublisher()

    case let .search(text):
//        return mutationSearchItems(by: text, packages: packages)
        return Just(.empty).eraseToAnyPublisher()

    case let .showAlert(error):
        return mutationShowAlert(with: error)
    
    case .showFeedError:
        return Just(.errorFeed).eraseToAnyPublisher()
    }

    // MARK: - Mutations
    func mutationFetchSections(packages: FeedPackages) -> AnyPublisher<FeedMutation, Never> {
        let fetchDocs = packages.itemsService.fetchQuery().share()

        let fetchFromDocs = fetchDocs
            .map { $0.query }
            .flatMap { packages.itemsService.fetchSectionsFromQuery($0) }
        
        return Publishers.Merge(
            fetchDocs
                .map { docs in
                    if docs.count > 0 {
                        return .updateSectionsPreloaders(count: docs.count)
                    } else {
                        return .empty
                    }
                }
                .catch { Just(.errorAlert(error: $0)) }
                .eraseToAnyPublisher()
                .withStatus(start: .progressViewStatus(status: .start), finish: .progressViewStatus(status: .stop))
            , fetchFromDocs
                .map { .updateSections($0) }
                .catch { Just(.errorAlert(error: $0)) })
        .eraseToAnyPublisher()
        
    }
//    func mutationSearchItems(by text: String, packages: FeedPackages) -> AnyPublisher<FeedMutation, Never> {
//        let fetchDocs = packages.itemsService.searchQuery(text)
//
//        let fetchFromDocs = fetchDocs
//            .flatMap { packages.itemsService.fetchItemsFromQuery($0.query) }
//
//        return fetchFromDocs
//            .map { .addItems(items: $0) }
//            .catch { Just(.errorAlert(error: $0)) }
//            .eraseToAnyPublisher()
//    }
    func mutationShowAlert(with error: Error) -> AnyPublisher<FeedMutation, Never> {
        Just(FeedMutation.errorAlert(error: error))
            .eraseToAnyPublisher()
    }
}
