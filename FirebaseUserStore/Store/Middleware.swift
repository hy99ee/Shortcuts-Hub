import Foundation
import Combine

protocol MiddlewareStoreType {
    associatedtype StoreState: StateType
    associatedtype StoreAction: Action
    associatedtype StorePackages: EnvironmentPackages
    associatedtype MiddlewareRedispatch: Error

    associatedtype Middleware = (StoreState, StoreAction) -> AnyPublisher<StoreAction, MiddlewareRedispatch>

    func dispatch(state: StoreState, action: StoreAction, packages: StorePackages) -> AnyPublisher<StoreAction, MiddlewareRedispatch>
}

typealias _MiddlewareStore = MiddlewareStore
final class MiddlewareStore<StoreState, StoreAction, StorePackages>: MiddlewareStoreType where StoreState: StateType,
                                                                                            StoreAction: Action,
                                                                                            StorePackages: EnvironmentPackages {
    enum MiddlewareRedispatch: Error {
        case redispatch(action: StoreAction)
    }

    typealias Middleware = (StoreState, StoreAction, StorePackages) -> AnyPublisher<StoreAction, MiddlewareRedispatch>

    private var middlewares: [Middleware]
    private var anyCancellables: Set<AnyCancellable> = []

    init(middlewares: [Middleware]) {
        self.middlewares = middlewares
    }

    func dispatch(state: StoreState, action: StoreAction, packages: StorePackages) -> AnyPublisher<StoreAction, MiddlewareRedispatch>  {
        Deferred {
            Future {[unowned self] promise in
                self.anyCancellables = []
                middlewares.publisher
                    .flatMap { $0(state, action, packages) }
                    .sink(receiveCompletion: {
                        switch $0 {
                        case .finished:
                            print("Successful finish middlewares flow with action: \(action)")
                            promise(.success(action))
                        case .failure(.redispatch(action: let action)):
                            print("Redispatch from middlewares flow with action: \(action)")
                            promise(.failure(.redispatch(action: action)))
                        }
                    }, receiveValue: { _ in })
                    .store(in: &anyCancellables)
            }
        }.eraseToAnyPublisher()
    }
}
