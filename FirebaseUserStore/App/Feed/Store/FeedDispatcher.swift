import Foundation
import Combine
import SwiftUI

struct FeedDispatcher<Service>: DispatcherType where Service: (ItemsServiceType & EnvironmentType) {
    typealias MutationType = FeedMutation
    typealias ServiceEnvironment = Service
    typealias ServiceError = Service.ServiceError

    var environment: Service

    func dispatch(_ action: FeedAction) -> AnyPublisher<MutationType, Never> {
        switch action {
        case .updateFeed:
            return mutationFetchItems.withStatus(start: FeedMutation.progressViewStatus(status: .start), finish: FeedMutation.progressViewStatus(status: .stop))
        case .addItem:
            return mutationAddItem.withStatus(start: FeedMutation.progressViewStatus(status: .start), finish: FeedMutation.progressViewStatus(status: .stop))
        case let .removeItem(id):
            return mutationRemoveItem(by: id)
        case let .showAboutSheet(sessionData):
            return mutationShowAboutSheet(data: sessionData)

        case .mockAction:
            return Empty(completeImmediately: true).eraseToAnyPublisher()
        }
    }
}

// MARK: - Mutations
extension FeedDispatcher {
    private var mutationFetchItems: AnyPublisher<FeedMutation, Never> {
        fetchPublisher
            .map { FeedMutation.fetchItems(newItems: $0) }
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .catch { Just(FeedMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }
    private var mutationAddItem: AnyPublisher<FeedMutation, Never> {
        addItemPublisher
            .map { FeedMutation.newItem(item: $0) }
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .catch { Just(FeedMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }
    private func mutationRemoveItem(by id: UUID) -> AnyPublisher<FeedMutation, Never> {
        removeItemRequest(id)
            .map { FeedMutation.removeItem(id: $0) }
            .catch { Just(FeedMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }
    private func mutationShowAboutSheet(data sessionData: SessionServiceSlice) -> AnyPublisher<FeedMutation, Never> {
        guard let user = sessionData.userDetails else { return Just(FeedMutation.errorAlert(error: SessionServiceError.undefinedUserDetails)).eraseToAnyPublisher() }

        return Just(FeedMutation.showAbout(data: AboutViewData(user: user, logout: sessionData.logout)))
            .eraseToAnyPublisher()
    }
// Loader
    private var mutationStartProgressView: AnyPublisher<FeedMutation, Never> {
        Just(FeedMutation.progressViewStatus(status: .start))
            .eraseToAnyPublisher()
    }
    private var mutationStopProgressView: AnyPublisher<FeedMutation, Never> {
        Just(FeedMutation.progressViewStatus(status: .stop))
            .eraseToAnyPublisher()
    }
}

// MARK: - Publishers
extension FeedDispatcher {
    private var fetchPublisher: AnyPublisher<[Item], ServiceError> {
        environment.fetchDishesByUserRequest()
            .eraseToAnyPublisher()
    }
    private var addItemPublisher: AnyPublisher<Item, ServiceError> {
        environment.setNewItemRequest()
            .flatMap { environment.fetchItemByID($0).eraseToAnyPublisher() }
            .eraseToAnyPublisher()
    }
    private func removeItemRequest(_ id: UUID) -> AnyPublisher<UUID, ServiceError> {
        environment.removeItemRequest(id)
            .eraseToAnyPublisher()
    }
}
