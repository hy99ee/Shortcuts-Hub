import SwiftUI
import Combine

final class StateStore<
    StoreState,
    StoreAction,
    StoreMutation,
    StorePackages,
    StoreTransition
>: ObservableObject, TransitionSender, Reinitable
where StoreState: StateType,
      StoreAction: Action,
      StoreMutation: Mutation,
      StorePackages: EnvironmentPackages,
      StoreTransition: TransitionType
{
    typealias StoreMiddlewareRepository = MiddlewareRepository<StoreState, StoreAction, StorePackages>
    typealias StoreDispatcher = DispatcherType<StoreAction, StoreMutation, StorePackages>
    typealias StoreReducer = ReducerType<StoreState, StoreMutation, StoreTransition>

    @Published private(set) var state: StoreState

    let transition = PassthroughSubject<StoreTransition, Never>()

    private(set) var packages: StorePackages
    private let reducer: StoreReducer
    private let dispatcher: StoreDispatcher
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
        self.middlewaresRepository = MiddlewareRepository(middlewares: middlewares, queue: queue)
    }

    func dispatch(_ action: StoreAction, isRedispatch: Bool = false) {
        middlewaresRepository.dispatch(state: state, action: action, packages: packages, isRedispatch: isRedispatch) // Middleware
            .subscribe(on: queue)
            .catch {[unowned self] in
                if case let StoreMiddlewareRepository.MiddlewareRedispatch.redispatch(actions, _) = $0 {
                    for action in actions {
                        self.dispatch(action, isRedispatch: true)
                    }
                }
                return Empty<StoreAction, StoreMiddlewareRepository.MiddlewareRedispatch>(completeImmediately: true)
            }
            .flatMap { [unowned self] in dispatcher($0, self.packages).receive(on: queue) } // Dispatch
            .subscribe(on: queue)
            .assertNoFailure()
            .receive(on: DispatchQueue.main)
            .flatMap { [unowned self] in reducer(state, $0) } // Reduce
            .subscribe(on: DispatchQueue.main)
            .compactMap({
                switch $0 {  
                case let .state(state):
                    return state
                case let .coordinate(destination):
                    self.transition.send(destination)
                    return nil
                }
            })
            .assign(to: &$state)
    }

    @discardableResult
    func reinit() -> Self {
        self.packages = self.packages.reinit()
        self.state = self.state.reinit()
        self.middlewaresRepository = self.middlewaresRepository.reinit()

        return self
    }
}
