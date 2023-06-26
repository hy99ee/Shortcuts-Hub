import Combine
import SwiftUI
import Firebase

let libraryDispatcher: DispatcherType<LibraryAction, LibraryMutation, LibraryPackages> = { action, packages in
    switch action {
    case .initLibrary, .updateLibrary:
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
            .merge(with: Just(LibraryMutation.setSearchFilter("")))
            .eraseToAnyPublisher()

    case let .click(item):
        return Just(.detail(item: item)).eraseToAnyPublisher()

    case let .addItem(item):
        return Just(.addItem(item)).eraseToAnyPublisher()

    case let .removeItem(item):
        return Just(.removeItem(item)).eraseToAnyPublisher()

    case let .removeFromLibrary(item):
        return mutationRemoveItemFromDatabase(item, packages: packages)
    
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
                        return .fastUpdate
                    }
                }
                .catch { Just(.errorAlert(error: $0)) }
                .eraseToAnyPublisher()
                .withStatus(start: .progressView(status: .start), finish: .progressView(status: .stop))
            , fetchFromDocs
                .delay(for: .seconds(1), scheduler: DispatchQueue.main)
                .map { .updateItems($0) }
                .catch { Just(.errorAlert(error: $0)) }
        )
        .eraseToAnyPublisher()
    }
    func mutationNextItems(packages: LibraryPackages) -> AnyPublisher<LibraryMutation, Never> {
        guard let lastCount = packages.itemsService.itemsServiceCursor?.count, lastCount > 0 else {
            return Empty().eraseToAnyPublisher()
        }

        let fetchDocs = packages.itemsService.nextQuery()

        let fetchFromDocs = fetchDocs
            .flatMap { packages.itemsService.fetchItemsFromQuery($0.query) }

        return fetchFromDocs
            .map { .appendItems($0) }
            .catch { Just(.errorAlert(error: $0)) }
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func mutationRemoveItemFromDatabase(_ item: Item, packages: LibraryPackages) -> AnyPublisher<LibraryMutation, Never> {
        packages.itemsService.removeItem(item)
            .handleEvents(
                receiveOutput: { _ in
                    packages.sessionService.firestoreMutation = .remove(item: item)
                }
            )
            .map { _ in .fastUpdate }
            .catch { Just(.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }

    func mutationSearchItems(by text: String, packages: LibraryPackages) -> AnyPublisher<LibraryMutation, Never> {
        let fetchDocs = packages.itemsService.searchQuery(text.lowercased())

        let fetchFromDocs = fetchDocs
            .flatMap { packages.itemsService.fetchItemsFromQuery($0.query, isPaginatable: false) }

        return fetchFromDocs
            .map { LibraryMutation.searchItems($0) }
            .catch { Just(LibraryMutation.errorAlert(error: $0)) }
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    func mutationShowAboutSheet(packages: LibraryPackages) -> AnyPublisher<LibraryMutation, Never> {
        guard packages.sessionService.state == .loggedIn else {
            return Just(.openLogin)
                .eraseToAnyPublisher()
        }

        guard packages.sessionService.userDetails.auth != nil,
              packages.sessionService.userDetails.value != nil
        else {
            return Just(.errorAlert(error: SessionServiceError.undefinedUserDetails))
                .eraseToAnyPublisher()
        }

        return Just(
            LibraryMutation.showAbout(
                AboutViewData(
                    user: packages.sessionService.userDetails,
                    logout: packages.sessionService.logout,
                    delete: packages.sessionService.deleteUser
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
