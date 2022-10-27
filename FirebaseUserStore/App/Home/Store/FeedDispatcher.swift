import Foundation
import Combine

struct FeedDispatcher<Service>: DispatcherType where Service: (ItemsServiceType & EnvironmentType) {
    typealias MutationType = FeedMutation
    typealias ServiceEnvironment = Service
    typealias ServiceError = Service.ServiceError

    var environment: Service

    func dispatch(_ action: FeedAction) -> AnyPublisher<MutationType, Never> {
        switch action {
        case .startAction:
            return Just(.startMutation).eraseToAnyPublisher()
        case  .updateFeed:
            return mutationFetchItems
        case .addItem:
            return mutationAddItem
        }
    }
}

// MARK: - Mutations
extension FeedDispatcher {
    private var mutationFetchItems: AnyPublisher<FeedMutation, Never> {
        fetchPublisher
            .map { FeedMutation.fetchItems(newItems: $0) }
            .eraseToAnyPublisher()
    }

    private var mutationAddItem: AnyPublisher<FeedMutation, Never> {
        addItemPublisher
            .map { FeedMutation.newItem(item: $0) }
            .catch { Just(FeedMutation.errorAlert(error: $0)) }
            .eraseToAnyPublisher()
    }

}

// MARK: - Publishers
extension FeedDispatcher {
    private var fetchPublisher: AnyPublisher<[Item], Never> {
        environment.fetchDishesByUserRequest()
            .catch { error -> AnyPublisher<[Item], Never> in
                print(error.localizedDescription)
                return Just([]).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private var addItemPublisher: AnyPublisher<Item, ServiceError> {
        environment.setNewItemRequest()
            .flatMap { environment.fetchItemByID($0).eraseToAnyPublisher() }
            .eraseToAnyPublisher()
            
    }
}
