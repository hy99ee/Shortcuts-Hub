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
        self.middlewareStore = MiddlewareStore(middlewares: middlewares)
    }
    
    func dispatch(_ action: Action, withMiddleware: Bool = true) {
        middlewareStore.dispatch(state: state, action: action) // Middleware
            .catch {[unowned self] in
                switch $0 {
                case let MiddlewareStore.MiddlewareRedispatch.redispatch(action):
                    self.dispatch(action)
                    return Empty<Action, MiddlewareStore.MiddlewareRedispatch>(completeImmediately: true)
                }
            }
            .subscribe(on: queue)
            .flatMap { [unowned self] in dispatcher.dispatch($0) } // Dispatch
            .assertNoFailure()
            .receive(on: DispatchQueue.main)
            .flatMap { [unowned self] in reducer(state, $0) } // Reduce
            .compactMap { $0 }
            .assign(to: &$state)
    }
}

