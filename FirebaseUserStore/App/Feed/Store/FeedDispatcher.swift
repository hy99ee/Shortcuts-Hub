import Combine
import SwiftUI
import Firebase

let feedDispatcher: DispatcherType<FeedAction, FeedMutation, FeedPackages> = { action, packages in
    switch action {
    case .updateFeed:
        return mutationFetchItems(packages: packages)

    case let .click(item):
        return Just(FeedMutation.detail(item: item)).eraseToAnyPublisher()

    case let .addItems(items):
        return Just(FeedMutation.addItems(items: items)).eraseToAnyPublisher()

    case let .search(text, local):
        return mutationSearchItems(by: text, local: local, packages: packages)

    case .clean:
        return Just(FeedMutation.clean).eraseToAnyPublisher()

    case .showAboutSheet:
        return mutationShowAboutSheet(packages: packages)

    case let .showAlert(error):
        return mutationShowAlert(with: error)
    
    case .showFeedError:
        return Just(FeedMutation.errorFeed).eraseToAnyPublisher()

    case .mockAction:
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }


    // MARK: - Mutations
    func mutationFetchItems(packages: FeedPackages) -> AnyPublisher<FeedMutation, Never> {
        let fetchDocs = packages.itemsService.fetchQuery().share()

        let fetchFromDocs = fetchDocs
            .map { $0.query }
            .flatMap { packages.itemsService.fetchItems($0, filter: { _ in true }) }
        
        return Publishers.Merge(
            fetchDocs
                .map { docs in
                    if docs.count > 0 {
                        return FeedMutation.fetchItemsPreloaders(count: docs.count)
                    } else {
                        return FeedMutation.empty
                    }
                }
                .catch { Just(FeedMutation.errorAlert(error: $0)) }
                .eraseToAnyPublisher()
                .withStatus(start: FeedMutation.progressViewStatus(status: .start), finish: FeedMutation.progressViewStatus(status: .stop))
            , fetchFromDocs
                .map { FeedMutation.fetchItems(newItems: $0) }
                .catch { Just(FeedMutation.errorAlert(error: $0)) })
        .eraseToAnyPublisher()
        
    }
    func mutationSearchItems(by text: String, local: Set<UUID>, packages: FeedPackages) -> AnyPublisher<FeedMutation, Never> {
        let fetchDocs = packages.itemsService.searchQuery(text)

        let fetchFromDocs = fetchDocs
            .flatMap {
                packages.itemsService.fetchItems($0.query) {
                    $0.title.lowercased().contains(text.lowercased()) && !local.contains($0.id)
                }
            }

        return fetchFromDocs
            .map { FeedMutation.addItems(items: $0) }
            .catch { Just(FeedMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }
    func mutationShowAboutSheet(packages: FeedPackages) -> AnyPublisher<FeedMutation, Never> {
        guard packages.sessionService.state == .loggedIn else { return Just(FeedMutation.login).eraseToAnyPublisher() }
        guard let user = packages.sessionService.userDetails else { return Just(FeedMutation.errorAlert(error: SessionServiceError.undefinedUserDetails)).eraseToAnyPublisher() }

        return Just(FeedMutation.showAbout(data: AboutViewData(user: user, logout: packages.sessionService.logout)))
            .eraseToAnyPublisher()
    }
    func mutationShowAlert(with error: Error) -> AnyPublisher<FeedMutation, Never> {
        Just(FeedMutation.errorAlert(error: error))
            .eraseToAnyPublisher()
    }
}
