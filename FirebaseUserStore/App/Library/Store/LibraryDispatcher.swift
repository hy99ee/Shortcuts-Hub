import Combine
import SwiftUI
import Firebase

let libraryDispatcher: DispatcherType<LibraryAction, LibraryMutation, LibraryPackages> = { action, packages in
    switch action {
    case .updateLibrary:
        return mutationFetchItems(packages: packages)
            .merge(with: Just(LibraryMutation.setSearchFilter("")))
            .eraseToAnyPublisher()

    case let .search(text):
        if text.isEmpty { return mutationFetchItems(packages: packages) }
        return Just(LibraryMutation.clean)
            .merge(with:
                    mutationSearchItems(by: text, packages: packages)
                .withStatus(start: .progressViewStatus(status: .start), finish: .progressViewStatus(status: .stop))
            )
            .eraseToAnyPublisher()

    case let .next(text):
        return mutationNextItems(by: text, packages: packages)
            .merge(with: Just(LibraryMutation.setSearchFilter("")))
            .eraseToAnyPublisher()

    case let .click(item):
        return Just(.detail(item: item)).eraseToAnyPublisher()

    case let .addItems(items):
        return Just(.addItems(items: items)).eraseToAnyPublisher()

    case let .removeItem(id):
        return mutationRemoveItem(by: id, packages: packages)

    case .clean:
        return Just(.clean).eraseToAnyPublisher()
    
    case let .changeSearchField(text):
        return Just(.setSearchFilter(text)).eraseToAnyPublisher()

    case .showAboutSheet:
        return mutationShowAboutSheet(packages: packages)

    case let .showAlert(error):
        return mutationShowAlert(with: error)
    
    case .showLibraryError:
        return Just(.errorLibrary).eraseToAnyPublisher()

    case .logout:
        return mutationLogout(packages: packages)

    case .deleteUser:
        return mutationDeleteThisUser(packages: packages)
    
    case .openLogin:
        return Just(.openLogin).eraseToAnyPublisher()

    case let .userLoginState(state):
        return Just(.changeUserLoginState(state)).eraseToAnyPublisher()

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
            .flatMap { packages.itemsService.fetchItemsFromQuery($0) }
        
        return Publishers.Merge(
            fetchDocs
                .map { (date, docs) in
                    let timeSpent = Date.now.timeIntervalSinceReferenceDate - date.timeIntervalSinceReferenceDate
                    if timeSpent < 1 { return .fastUpdate }

                    if docs.count > 0 {
                        return .updateItemsPreloaders(count: docs.count)
                    } else {
                        return .empty
                    }
                }
                .catch { Just(.errorAlert(error: $0)) }
                .eraseToAnyPublisher()
                .withStatus(start: LibraryMutation.progressViewStatus(status: .start), finish: LibraryMutation.progressViewStatus(status: .stop))
            , fetchFromDocs
                .delay(for: .seconds(1), scheduler: DispatchQueue.main)
                .map { .fetchedItems(newItems: $0) }
                .catch { Just(.errorAlert(error: $0)) }
        )
        .eraseToAnyPublisher()
    }
    func mutationNextItems(by text: String, packages: LibraryPackages) -> AnyPublisher<LibraryMutation, Never> {
        let fetchDocs = packages.itemsService.nextQuery(text)

        let fetchFromDocs = fetchDocs
            .filter { $0.count != 0 }
            .flatMap { packages.itemsService.fetchItemsFromQuery($0.query) }

        return fetchFromDocs
            .map { .fetchedNewItems($0) }
            .catch { Just(.errorAlert(error: $0)) }
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    func mutationRemoveItem(by id: UUID, packages: LibraryPackages) -> AnyPublisher<LibraryMutation, Never> {
        packages.itemsService.removeItem(id)
            .map { .removeItem(id: $0) }
            .catch { Just(.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }
    func mutationSearchItems(by text: String, packages: LibraryPackages) -> AnyPublisher<LibraryMutation, Never> {
        let fetchDocs = packages.itemsService.searchQuery(text)

        let fetchFromDocs = fetchDocs
            .flatMap { packages.itemsService.fetchItemsFromQuery($0.query) }

        return fetchFromDocs
            .map { LibraryMutation.fetchedItems(newItems: $0) }
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
