import SwiftUI
import Combine

final class StateStore<StoreState, StoreDispatcher>:
    ObservableObject where StoreState: StateType,
                           StoreDispatcher: DispatcherType {
    typealias Action = StoreDispatcher.ActionType
    typealias Middleware = (StoreState, Action) -> AnyPublisher<Action, MiddlewareError>
    typealias ZipMiddleware = (Middleware, Middleware?)
    typealias MiddlewareResult = (ZipMiddleware) -> AnyPublisher<Action, Never>
    typealias Reducer = ReducerType<StoreState, StoreDispatcher.MutationType>

    @Published var state: StoreState

    var reducer: Reducer
    var dispatcher: StoreDispatcher
    var middlewares: [Middleware]

    private let queue = DispatchQueue(label: "com.state", qos: .userInitiated)
    private let startDispatch: PassthroughSubject<Void, Never> = .init()
    private var anyCancellables: Set<AnyCancellable> = []

    init(
        state: StoreState,
        dispatcher: StoreDispatcher,
        reducer: @escaping Reducer
    ) {
        self.state = state
        self.dispatcher = dispatcher
        self.reducer = reducer
        self.middlewares = []
        self.middlewares = [mockMiddleware1, mockMiddleware2, mockMiddleware3]
        
        
    }
    
    func dispatch(_ action: Action) {
        middlewares.publisher
            .flatMap({[unowned self] in $0(state, action) })
            .sink(receiveCompletion: {[unowned self] in
                switch $0 {
                case .finished: _dispatch(action)
                case .failure(.redispatch(action: let action)):
                    self.middlewares = []
                    print("Redispatch with action: \(action)")
                    self.dispatch(action)
                }
            }, receiveValue: { _ in })
            .store(in: &anyCancellables)
    }
    
    private func _dispatch(_ action: Action) {
        dispatcher
            .dispatch(action)
            .subscribe(on: queue)
            .receive(on: DispatchQueue.main)
            .flatMap { [unowned self] in reducer(state, $0) }
            .compactMap { $0 }
            .assign(to: &$state)
    }
    
    lazy var mockMiddleware1: Middleware = { _, action in
        print("---> Middleware 1")
        return Just(action).setFailureType(to: MiddlewareError.self).eraseToAnyPublisher()
    }

    lazy var mockMiddleware2: Middleware = { _, action in
        print("---> Middleware 2")
//        return Just(action).setFailureType(to: MiddlewareError.self).eraseToAnyPublisher()
        return Fail(error: MiddlewareError.redispatch(action: FeedAction.updateFeed as! StoreDispatcher.ActionType)).eraseToAnyPublisher()
    }

    lazy var mockMiddleware3: Middleware = { _, action in
        print("---> Middleware 3")
        return Just(action).setFailureType(to: MiddlewareError.self).eraseToAnyPublisher()
    }
}

extension StateStore {
    enum MiddlewareError: Error {
        case redispatch(action: Action)
    }
    
    func middlewaresResult(action: Action, middlewares: [Middleware]) -> AnyPublisher<Action, MiddlewareError> {
        middlewares.publisher
            .flatMap({[unowned self] in $0(state, action) })
            .eraseToAnyPublisher()
    }


}



