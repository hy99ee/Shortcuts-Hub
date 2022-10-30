import SwiftUI
import Combine

final class StateStore<StoreState, StoreDispatcher>:
    ObservableObject where StoreState: StateType,
                           StoreDispatcher: DispatcherType {
    typealias MiddlewareStore = _MiddlewareStore<StoreState, Action>
    typealias Action = StoreDispatcher.ActionType
    typealias Reducer = ReducerType<StoreState, StoreDispatcher.MutationType>

    @Published var state: StoreState

    var reducer: Reducer
    var dispatcher: StoreDispatcher
//    var middlewares: [Middleware]
    var middlewareStore: MiddlewareStore!

    private let queue = DispatchQueue(label: "com.state", qos: .userInitiated)
    private var anyCancellables: Set<AnyCancellable> = []

    init(
        state: StoreState,
        dispatcher: StoreDispatcher,
        reducer: @escaping Reducer,
        middlewares: [MiddlewareStore.Middleware] = []
    ) {
        self.state = state
        self.dispatcher = dispatcher
        self.reducer = reducer

        let mock_middlewares = [mockMiddleware1, mockMiddleware3]
        self.middlewareStore = MiddlewareStore(middlewares: mock_middlewares)
        
    }
    
//    func dispatch(_ action: Action) {
//        middlewareStore.dispatch(state: state, action: action).output
////        middlewares.publisher
////            .flatMap({[unowned self] in $0(state, action) })
//            .sink(receiveCompletion: {[unowned self] in
//                switch $0 {
//                case .finished: _dispatch(action)
//                case .failure(.redispatch(action: let action)):
//                    self.middlewares = []
//                    print("Redispatch with action: \(action)")
//                    self.dispatch(action)
//                }
//            }, receiveValue: { _ in })
//            .store(in: &anyCancellables)
//    }
    
    func dispatch(_ action: Action) {
        middlewareStore.dispatch(state: state, action: action).output // Middleware
            .catch {[unowned self] in
                switch $0 {
                case let MiddlewareStore.MiddlewareRedispatch.redispatch(action):
                    self.dispatch(action)
                    return Empty<Action, MiddlewareStore.MiddlewareRedispatch>(completeImmediately: true)
                }
            }
            .print("------> ")
            .subscribe(on: queue)
            .flatMap { [unowned self] in dispatcher.dispatch($0) } // Dispatch
            .assertNoFailure()
            .receive(on: DispatchQueue.main)
            .flatMap { [unowned self] in reducer(state, $0) } // Reduce
            .compactMap { $0 }
            .assign(to: &$state)
    }
    
    lazy var mockMiddleware1: MiddlewareStore.Middleware = { _, action in
        print("---> Middleware 1")
        return Just(action).setFailureType(to: MiddlewareStore.MiddlewareRedispatch.self).eraseToAnyPublisher()
    }

    lazy var mockMiddleware2: MiddlewareStore.Middleware = { _, action in
        print("---> Middleware 2")
//        return Just(action).setFailureType(to: MiddlewareError.self).eraseToAnyPublisher()
        return Fail(error: MiddlewareStore.MiddlewareRedispatch.redispatch(action: FeedAction.updateFeed as! StoreDispatcher.ActionType)).eraseToAnyPublisher()
    }

    lazy var mockMiddleware3: MiddlewareStore.Middleware = { _, action in
        print("---> Middleware 3")
        return Just(action).setFailureType(to: MiddlewareStore.MiddlewareRedispatch.self).eraseToAnyPublisher()
    }
}

//extension StateStore {
//    enum MiddlewareError: Error {
//        case redispatch(action: Action)
//    }
//
//    func middlewaresResult(action: Action, middlewares: [Middleware]) -> AnyPublisher<Action, MiddlewareError> {
//        middlewares.publisher
//            .flatMap({[unowned self] in $0(state, action) })
//            .eraseToAnyPublisher()
//    }
//
//
//}



