import Foundation
import Combine

protocol MiddlewareStoreType {
    associatedtype StoreState: StateType
    associatedtype StoreAction: Action
    associatedtype MiddlewareRedispatch: Error

    associatedtype Middleware = (StoreState, StoreAction) -> AnyPublisher<StoreAction, MiddlewareRedispatch>

    func dispatch(state: StoreState, action: StoreAction) -> AnyPublisher<StoreAction, MiddlewareRedispatch>
}

typealias _MiddlewareStore = MiddlewareStore
final class MiddlewareStore<StoreState, StoreAction>: MiddlewareStoreType where StoreState: StateType, StoreAction: Action {
    enum MiddlewareRedispatch: Error {
        case redispatch(action: StoreAction)
    }

    typealias Middleware = (StoreState, StoreAction) -> AnyPublisher<StoreAction, MiddlewareRedispatch>

    let output: PassthroughSubject<StoreAction, MiddlewareRedispatch> = .init()

    private var middlewares: [Middleware]
    private var anyCancellables: Set<AnyCancellable> = []

    init(middlewares: [Middleware]) {
        self.middlewares = middlewares
    }

    func dispatch(state: StoreState, action: StoreAction) -> AnyPublisher<StoreAction, MiddlewareRedispatch>  {
        Deferred {
            Future {[unowned self] promise in
                middlewares.publisher
                    .flatMap { $0(state, action) }
                    .sink(receiveCompletion: {
                        switch $0 {
                        case .finished:
                            print("Success with action: \(action)")
                            promise(.success(action))
                        case .failure(.redispatch(action: let action)):
                            print("Redispatch with action: \(action)")
                            promise(.failure(.redispatch(action: action)))
                        }
                    }, receiveValue: { _ in })
                    .store(in: &anyCancellables)
            }
        }.eraseToAnyPublisher()
    }
}
