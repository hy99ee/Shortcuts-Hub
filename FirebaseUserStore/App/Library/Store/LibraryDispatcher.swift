import Combine
import SwiftUI
import Firebase

let libraryDispatcher: DispatcherType<LibraryAction, LibraryMutation, LibraryPackages> = { action, packages in
    switch action {
    case .updateLibrary:
        return mutationFetchItems(packages: packages)

    case let .click(item):
        return Just(LibraryMutation.detail(item: item)).eraseToAnyPublisher()

    case let .addItems(items):
        return Just(LibraryMutation.addItems(items: items)).eraseToAnyPublisher()

    case .addItem:
        return mutationAddItem(packages: packages).withStatus(start: LibraryMutation.progressButtonStatus(status: .start), finish: LibraryMutation.progressButtonStatus(status: .stop))

    case let .removeItem(id):
        return mutationRemoveItem(by: id, packages: packages)

    case let .search(text, local):
        return mutationSearchItems(by: text, local: local, packages: packages)

    case .clean:
        return Just(LibraryMutation.clean).eraseToAnyPublisher()

    case .showAboutSheet:
        return mutationShowAboutSheet(packages: packages)

    case let .showAlert(error):
        return mutationShowAlert(with: error)
    
    case .showLibraryError:
        return Just(LibraryMutation.errorLibrary).eraseToAnyPublisher()

    case .logout:
        return mutationLogout(packages: packages)

    case .mockAction:
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }


    // MARK: - Mutations
    func mutationFetchItems(packages: LibraryPackages) -> AnyPublisher<LibraryMutation, Never> {
        let fetchDocs = packages.itemsService.fetchQuery().share()

        let fetchFromDocs = fetchDocs
            .map { $0.query }
            .flatMap { packages.itemsService.fetchItems($0) }
        
        return Publishers.Merge(
            fetchDocs
                .map { docs in
                    if docs.count > 0 {
                        return LibraryMutation.fetchItemsPreloaders(count: docs.count)
                    } else {
                        return LibraryMutation.empty
                    }
                }
                .catch { Just(LibraryMutation.errorAlert(error: $0)) }
                .eraseToAnyPublisher()
                .withStatus(start: LibraryMutation.progressViewStatus(status: .start), finish: LibraryMutation.progressViewStatus(status: .stop))
            , fetchFromDocs
                .map { LibraryMutation.fetchItems(newItems: $0) }
                .catch { Just(LibraryMutation.errorAlert(error: $0)) })
        .eraseToAnyPublisher()
        
    }
    func mutationAddItem(packages: LibraryPackages) -> AnyPublisher<LibraryMutation, Never> {
        packages.itemsService.setNewItemRequest()
            .flatMap { packages.itemsService.fetchItem($0).eraseToAnyPublisher() }
            .map { LibraryMutation.newItem(item: $0) }
            .catch { Just(LibraryMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }
    func mutationRemoveItem(by id: UUID, packages: LibraryPackages) -> AnyPublisher<LibraryMutation, Never> {
        packages.itemsService.removeItemRequest(id)
            .map { LibraryMutation.removeItem(id: $0) }
            .catch { Just(LibraryMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }
    func mutationSearchItems(by text: String, local: Set<UUID>, packages: LibraryPackages) -> AnyPublisher<LibraryMutation, Never> {
        let fetchDocs = packages.itemsService.searchQuery(text)

        let fetchFromDocs = fetchDocs
            .flatMap {
                packages.itemsService.fetchItems($0.query) {
                    $0.title.lowercased().contains(text.lowercased()) && !local.contains($0.id)
                }
            }

        return fetchFromDocs
            .map { LibraryMutation.addItems(items: $0) }
            .catch { Just(LibraryMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }
    func mutationShowAboutSheet(packages: LibraryPackages) -> AnyPublisher<LibraryMutation, Never> {
        guard packages.sessionService.state == .loggedIn else { return Just(LibraryMutation.login).eraseToAnyPublisher() }
        guard let user = packages.sessionService.userDetails else { return Just(LibraryMutation.errorAlert(error: SessionServiceError.undefinedUserDetails)).eraseToAnyPublisher() }

        return Just(LibraryMutation.showAbout(data: AboutViewData(user: user, logout: packages.sessionService.logout)))
            .eraseToAnyPublisher()
    }
    func mutationShowAlert(with error: Error) -> AnyPublisher<LibraryMutation, Never> {
        Just(LibraryMutation.errorAlert(error: error))
            .eraseToAnyPublisher()
    }
    func mutationLogout(packages: LibraryPackages) -> AnyPublisher<LibraryMutation, Never> {
        Just(())
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .handleEvents(receiveOutput: { packages.sessionService.logout() })
            .map { LibraryMutation.logout }
            .eraseToAnyPublisher()
    }
}
