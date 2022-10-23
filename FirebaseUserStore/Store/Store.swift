import SwiftUI
import Combine

final class StateStore<StoreState, StoreDispatcher, StoreEnvironment, StoreMiddleware>:
    ObservableObject where StoreState: StateType,
                           StoreDispatcher: DispatcherType,
                           StoreEnvironment: EnvironmentType,
                           StoreMiddleware: MiddlewareType,
                           StoreEnvironment == StoreDispatcher.ServiceEnvironment{

    @Published var state: StoreState
    var reducer: ReducerType<StoreState>
    var dispatcher: StoreDispatcher
    var environment: StoreEnvironment
    var middleware: [StoreMiddleware]
    
    private let lock = NSLock()

    init(
        state: StoreState,
        dispatcher: StoreDispatcher,
        environment: StoreEnvironment,
        middleware: [StoreMiddleware] = [],
        reducer: @escaping ReducerType<StoreState>
    ) {
        self.state = state
        self.dispatcher = dispatcher
        self.environment = environment
        self.middleware = middleware
        self.reducer = reducer
    }
    
    func dispatch<Action>(_  action: Action) where Action == StoreDispatcher.ActionType {
        let mappedAction = {
            var actionForMap = action
            self.middleware.forEach { middleware in
                let action = middleware.middlewareMap(actionForMap, nil)
                if action != nil { actionForMap = action! }
            }
            return actionForMap
        }()

        dispatcher
            .dispatch(mappedAction, environment: environment)
            .flatMap { [unowned self] in reducer(state, $0) }
            .compactMap { $0 }
            .assign(to: &$state)
    }
}


