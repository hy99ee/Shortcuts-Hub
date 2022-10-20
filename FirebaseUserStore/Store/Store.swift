import SwiftUI
import Combine

final class StateStore<StoreState, StoreDispatcher, StoreEnvironment>:
    ObservableObject where StoreState: StateType,
                           StoreDispatcher: DispatcherType,
                           StoreEnvironment: EnvironmentType {

    @Published var state: StoreState
    var reducer: ReducerType<StoreState>
    var dispatcher: StoreDispatcher
    var environment: StoreEnvironment
    
    private let lock = NSLock()

    init(
        state: StoreState,
        dispatcher: StoreDispatcher,
        environment: StoreEnvironment,
        reducer: @escaping ReducerType<StoreState>
    ) {
        self.state = state
        self.dispatcher = dispatcher
        self.reducer = reducer
        self.environment = environment
    }

//    private func commit<Mutation>(_ mutation: Mutation) -> AnyPublisher<StoreState, Never> where Mutation == Reducer.MutationType {
//        reducer.reduce(state: state, mutation: mutation)
//    }
    
    func dispatch<Action>(_ action: Action) where Action == StoreDispatcher.ActionType {
        dispatcher
            .dispatch(action: action)
            .flatMap {[unowned self] in
                reducer(&state, $0, environment)
            }
        
            .assign(to: &$state)
    }
}

//extension Publisher where Output: Mutation, Failure == Never {
//    func commit<State: StateType>(_ commit: @escaping (Output) -> AnyPublisher<State, Never>) -> AnyPublisher<State, Never> {
//        self.flatMap { commit($0) }.eraseToAnyPublisher()
//    }
//}

