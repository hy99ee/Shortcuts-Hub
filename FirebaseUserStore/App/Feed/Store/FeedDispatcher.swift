import Foundation
import Combine

struct FeedDispatcher<Service>: DispatcherType where Service: (ItemsServiceType & EnvironmentType) {
    typealias MutationType = FeedMutation
    typealias ServiceEnvironment = Service
    typealias ServiceError = Service.ServiceError

    var environment: Service

    func dispatch(_ action: FeedAction) -> AnyPublisher<MutationType, Never> {
        switch action {
        case .updateFeed:
            return mutationFetchItems
        case .addItem:
            return mutationAddItem
        case let .removeItem(id):
            return mutationRemoveItem(by: id)
        case let .showAboutSheet(sessionData):
            return mutationShowAboutSheet(data: sessionData)
        }
    }
}

// MARK: - Mutations
extension FeedDispatcher {
    private var mutationFetchItems: AnyPublisher<FeedMutation, Never> {
        fetchPublisher
            .map { FeedMutation.fetchItems(newItems: $0) }
            .catch { Just(FeedMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }

    private var mutationAddItem: AnyPublisher<FeedMutation, Never> {
        addItemPublisher
            .map { FeedMutation.newItem(item: $0) }
            .catch { Just(FeedMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }

    private func mutationRemoveItem(by id: UUID) -> AnyPublisher<FeedMutation, Never> {
        environment.removeItemRequest(id)
            .map { FeedMutation.removeItem(id: $0) }
            .catch { Just(FeedMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }

    private func mutationShowAboutSheet(data sessionData: SessionServiceSlice) -> AnyPublisher<FeedMutation, Never> {
        guard let user = sessionData.userDetails else { return Empty(completeImmediately: true).eraseToAnyPublisher() }

        return Just(FeedMutation.showAbout(aboutData: AboutViewData(user: user, logout: sessionData.logout)))
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
}
