import Combine
import SwiftUI
import Firebase

let libraryDispatcher: DispatcherType<LibraryAction, LibraryMutation, LibraryPackages> = { action, packages in
    switch action {
    case .updateLibrary:
        return mutationFetchItems(packages: packages)
            .eraseToAnyPublisher()

    case let .click(item):
        return Just(LibraryMutation.detail(item: item)).eraseToAnyPublisher()

    case let .addItems(items):
        return Just(LibraryMutation.addItems(items: items)).eraseToAnyPublisher()

    case let .removeItem(id):
        return mutationRemoveItem(by: id, packages: packages)

    case let .search(text, local):
        return mutationSearchItems(by: text, local: local, packages: packages)
            .eraseToAnyPublisher()

    case .clean:
        return Just(LibraryMutation.clean).eraseToAnyPublisher()
    
    case let .changeSearchField(text):
        return Just(LibraryMutation.setSearchFilter(text)).eraseToAnyPublisher()

    case .showAboutSheet:
        return mutationShowAboutSheet(packages: packages)

    case let .showAlert(error):
        return mutationShowAlert(with: error)
    
    case .showLibraryError:
        return Just(LibraryMutation.errorLibrary).eraseToAnyPublisher()

    case .logout:
        return mutationLogout(packages: packages)

    case .deleteUser:
        return mutationDeleteThisUser(packages: packages)
    
    case .openLogin:
        return Just(LibraryMutation.openLogin).eraseToAnyPublisher()

    case let .userLoginState(state):
        return Just(LibraryMutation.changeUserLoginState(state)).eraseToAnyPublisher()

    case .mockAction:
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }


    // MARK: - Mutations
    func mutationFetchItems(packages: LibraryPackages) -> AnyPublisher<LibraryMutation, Never> {
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
            .flatMap { packages.itemsService.fetchItems($0) }
        
        return Publishers.Merge(
            fetchDocs
                .map { (date, docs) in
                    let timeSpent = Date.now.timeIntervalSinceReferenceDate - date.timeIntervalSinceReferenceDate
                    if timeSpent < 1 { return .fastUpdate }

                    if docs.count > 0 {
                        return .fetchItemsPreloaders(count: docs.count)
                    } else {
                        return .empty
                    }
                }
                .catch { Just(.errorAlert(error: $0)) }
                .eraseToAnyPublisher()
                .withStatus(start: LibraryMutation.progressViewStatus(status: .start), finish: LibraryMutation.progressViewStatus(status: .stop))
            , fetchFromDocs
                .delay(for: .seconds(1), scheduler: DispatchQueue.main)
                .map { .fetchItems(newItems: $0) }
                .catch { Just(.errorAlert(error: $0)) }
        )
        .eraseToAnyPublisher()
        
    }
    func mutationRemoveItem(by id: UUID, packages: LibraryPackages) -> AnyPublisher<LibraryMutation, Never> {
        packages.itemsService.removeItem(id)
            .map { .removeItem(id: $0) }
            .catch { Just(.errorAlert(error: $0)) }
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
            .catch { Just(.errorAlert(error: $0)) }
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    func mutationShowAboutSheet(packages: LibraryPackages) -> AnyPublisher<LibraryMutation, Never> {
        guard packages.sessionService.state == .loggedIn else { return Just(LibraryMutation.openLogin).eraseToAnyPublisher() }
        guard let user = packages.sessionService.userDetails else { return Just(LibraryMutation.errorAlert(error: SessionServiceError.undefinedUserDetails)).eraseToAnyPublisher() }

        return Just(
            LibraryMutation.showAbout(
                AboutViewData(
                    user: user,
                    logout: packages.sessionService.logout,
                    deleteUser: packages.sessionService.deleteUser
                )
            )
        )
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
            .map { LibraryMutation.hasLogout }
            .eraseToAnyPublisher()
    }

    func mutationDeleteThisUser(packages: LibraryPackages) -> AnyPublisher<LibraryMutation, Never> {
        Just(())
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .handleEvents(receiveOutput: { packages.sessionService.deleteUser() })
            .map { LibraryMutation.hasDeletedUser }
            .eraseToAnyPublisher()
    }
}
