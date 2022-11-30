import Foundation
import Combine
import SwiftUI

struct FeedDispatcher: DispatcherType {
    typealias MutationType = FeedMutation
    
    typealias EnvironmentPackagesType = FeedPackages
    typealias ServiceError = EnvironmentPackagesType.PackageItemsService.ServiceError

    private let session = SessionService.shared

    func dispatch(_ action: FeedAction, packages: EnvironmentPackagesType) -> AnyPublisher<MutationType, Never> {
        switch action {
        case .updateFeed:
            return mutationFetchItems(packages: packages).withStatus(start: FeedMutation.progressViewStatus(status: .start), finish: FeedMutation.progressViewStatus(status: .stop))
        case .addItem:
            return mutationAddItem(packages: packages).withStatus(start: FeedMutation.progressViewStatus(status: .start), finish: FeedMutation.progressViewStatus(status: .stop))
        case let .removeItem(id):
            return mutationRemoveItem(by: id, packages: packages)
        case .showAboutSheet:
            return mutationShowAboutSheet

        case .mockAction:
            return Empty(completeImmediately: true).eraseToAnyPublisher()
        }
    }
}

// MARK: - Mutations
extension FeedDispatcher {
    private func mutationFetchItems(packages: EnvironmentPackagesType) -> AnyPublisher<FeedMutation, Never> {
        packages.itemsService.fetchDishesByUserRequest()
            .map { FeedMutation.fetchItems(newItems: $0) }
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .catch { Just(FeedMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }
    private func mutationAddItem(packages: EnvironmentPackagesType) -> AnyPublisher<FeedMutation, Never> {
        packages.itemsService.setNewItemRequest()
            .flatMap { packages.itemsService.fetchItemByID($0).eraseToAnyPublisher() }
            .map { FeedMutation.newItem(item: $0) }
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .catch { Just(FeedMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }
    private func mutationRemoveItem(by id: UUID, packages: EnvironmentPackagesType) -> AnyPublisher<FeedMutation, Never> {
        packages.itemsService.removeItemRequest(id)
            .map { FeedMutation.removeItem(id: $0) }
            .catch { Just(FeedMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }
    private var mutationShowAboutSheet: AnyPublisher<FeedMutation, Never> {
        guard let user = session.userDetails else { return Just(FeedMutation.errorAlert(error: SessionServiceError.undefinedUserDetails)).eraseToAnyPublisher() }

        return Just(FeedMutation.showAbout(data: AboutViewData(user: user, logout: session.logout)))
            .eraseToAnyPublisher()
    }
}
