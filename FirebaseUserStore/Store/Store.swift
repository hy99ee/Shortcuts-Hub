import SwiftUI
import Combine

final class StateStore<StoreState, StoreDispatcher, StorePackages>:
    ObservableObject where StoreState: StateType,
                           StoreDispatcher: DispatcherType,
                           StorePackages: EnvironmentPackages,
                           StoreDispatcher.EnvironmentPackagesType == StorePackages {
    typealias MiddlewareStore = _MiddlewareStore<StoreState, Action, StorePackages>
    typealias Action = StoreDispatcher.ActionType
    typealias Reducer = ReducerType<StoreState, StoreDispatcher.MutationType>

    @Published var state: StoreState

    private let reducer: Reducer
    private let dispatcher: StoreDispatcher
    private let packages: StorePackages
//    private let middlewares: [MiddlewareStore.Middleware]
    private var middlewaresStore: MiddlewareStore

    private let queue = DispatchQueue(label: "com.state", qos: .userInitiated)

    init(
        state: StoreState,
        dispatcher: StoreDispatcher,
        reducer: @escaping Reducer,
        packages: StorePackages,
        middlewares: [MiddlewareStore.Middleware] = []
    ) {
        self.state = state
        self.dispatcher = dispatcher
        self.reducer = reducer
        self.packages = packages
//        self.middlewares = middlewares
        self.middlewaresStore = MiddlewareStore(middlewares: middlewares)
    }
    
    func dispatch(_ action: Action, isRedispatch: Bool = false) {
        middlewaresStore.dispatch(state: state, action: action, packages: packages, isRedispatch: isRedispatch) // Middleware
            .catch {[unowned self] in
                switch $0 {
                case let MiddlewareStore.MiddlewareRedispatch.redispatch(action, _):
                    self.dispatch(action, isRedispatch: true)
                    return Empty<Action, MiddlewareStore.MiddlewareRedispatch>(completeImmediately: true)
                case .stopFlow:
                    return Empty<Action, MiddlewareStore.MiddlewareRedispatch>(completeImmediately: true)
                }
            }
            .subscribe(on: queue)
            .flatMap { [unowned self] in dispatcher.dispatch($0, packages: self.packages) } // Dispatch
            .assertNoFailure()
            .receive(on: DispatchQueue.main)
            .flatMap { [unowned self] in reducer(state, $0) } // Reduce
            .compactMap { $0 }
            .assign(to: &$state)
    }

//    private func middlewareStore(_ isRedispatch: Bool) -> MiddlewareStore {
//        if !isRedispatch { middlewaresStore.middlewares = middlewares }
//        return middlewaresStore
//    }
}

