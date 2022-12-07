import SwiftUI
import Combine

final class StateStore<StoreState, StoreAction, StoreMutation, StorePackages>:
    ObservableObject where StoreState: StateType,
                           StoreAction: Action,
                           StoreMutation: Mutation,
                           StorePackages: EnvironmentPackages {

    typealias StoreMiddlewareRepository = MiddlewareRepository<StoreState, StoreAction, StorePackages>
    typealias StoreDispatcher = DispatcherType<StoreAction, StoreMutation, StorePackages>
    typealias StoreReducer = ReducerType<StoreState, StoreMutation>

    @Published var state: StoreState

    private let reducer: StoreReducer
    private let dispatcher: StoreDispatcher
    private let packages: StorePackages
    private var middlewaresRepository: StoreMiddlewareRepository

    private let queue = DispatchQueue(label: "com.state", qos: .userInitiated)

    init(
        state: StoreState,
        dispatcher: @escaping StoreDispatcher,
        reducer: @escaping StoreReducer,
        packages: StorePackages,
        middlewares: [StoreMiddlewareRepository.Middleware] = []
    ) {
        self.state = state
        self.dispatcher = dispatcher
        self.reducer = reducer
        self.packages = packages
        self.middlewaresRepository = MiddlewareRepository(middlewares: middlewares)
    }

    func dispatch(_ action: StoreAction, isRedispatch: Bool = false) {
        middlewaresRepository.dispatch(state: state, action: action, packages: packages, isRedispatch: isRedispatch) // Middleware
            .catch {[unowned self] in
                switch $0 {
                case let StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(action, _):
                    self.dispatch(action, isRedispatch: true)
                    return Empty<StoreAction, StoreMiddlewareRepository.MiddlewareRedispatch>(completeImmediately: true)
                case .stopFlow:
                    return Empty<StoreAction, StoreMiddlewareRepository.MiddlewareRedispatch>(completeImmediately: true)
                }
            }
            .subscribe(on: queue)
            .flatMap { [unowned self] in dispatcher($0, self.packages) } // Dispatch
            .assertNoFailure()
            .receive(on: DispatchQueue.main)
            .flatMap { [unowned self] in reducer(state, $0) } // Reduce
            .subscribe(on: DispatchQueue.main)
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .assign(to: &$state)
    }
}
