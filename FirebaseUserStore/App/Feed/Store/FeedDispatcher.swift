import Foundation
import Combine
import SwiftUI

let feedDispatcher: DispatcherType<FeedAction, FeedMutation, FeedPackages> = { action, packages in
    switch action {
    case .updateFeed:
        return mutationFetchItems(packages: packages).withStatus(start: FeedMutation.progressViewStatus(status: .start), finish: FeedMutation.progressViewStatus(status: .stop))
    case .addItem:
        return mutationAddItem(packages: packages).withStatus(start: FeedMutation.progressButtonStatus(status: .start), finish: FeedMutation.progressButtonStatus(status: .stop))
    case let .removeItem(id):
        return mutationRemoveItem(by: id, packages: packages)
    case .showAboutSheet:
        return mutationShowAboutSheet(packages: packages)
    case let .showAlert(error):
        return mutationShowAlert(with: error)
    case .logout:
        return mutationLogout(packages: packages)
    case .mockAction:
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }


    // MARK: - Mutations
    func mutationFetchItems(packages: FeedPackages) -> AnyPublisher<FeedMutation, Never> {
        packages.itemsService.fetchDishesByUserRequest()
            .map { FeedMutation.fetchItems(newItems: $0) }
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .catch { Just(FeedMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }
    func mutationAddItem(packages: FeedPackages) -> AnyPublisher<FeedMutation, Never> {
        packages.itemsService.setNewItemRequest()
            .flatMap { packages.itemsService.fetchItemByID($0).eraseToAnyPublisher() }
            .map { FeedMutation.newItem(item: $0) }
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .catch { Just(FeedMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }
    func mutationRemoveItem(by id: UUID, packages: FeedPackages) -> AnyPublisher<FeedMutation, Never> {
        packages.itemsService.removeItemRequest(id)
            .map { FeedMutation.removeItem(id: $0) }
            .catch { Just(FeedMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }
    func mutationShowAboutSheet(packages: FeedPackages) -> AnyPublisher<FeedMutation, Never> {
        guard let user = packages.sessionService.userDetails else { return Just(FeedMutation.errorAlert(error: SessionServiceError.undefinedUserDetails)).eraseToAnyPublisher() }
        return Just(FeedMutation.showAbout(data: AboutViewData(user: user, logout: packages.sessionService.logout)))
            .eraseToAnyPublisher()
    }
    func mutationShowAlert(with error: Error) -> AnyPublisher<FeedMutation, Never> {
        Just(FeedMutation.errorAlert(error: error))
            .eraseToAnyPublisher()
    }
    func mutationLogout(packages: FeedPackages) -> AnyPublisher<FeedMutation, Never> {
        Just(())
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .handleEvents(receiveOutput: { packages.sessionService.logout() })
            .map { FeedMutation.logout }
            .eraseToAnyPublisher()
    }
}
