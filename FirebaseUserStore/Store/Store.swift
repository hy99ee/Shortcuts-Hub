import SwiftUI
import Combine

final class StateStore<StoreState, StoreDispatcher>:
    ObservableObject where StoreState: StateType,
                           StoreDispatcher: DispatcherType {

    @Published var state: StoreState
    var reducer: ReducerType<StoreState, StoreDispatcher.MutationType>
    var dispatcher: StoreDispatcher

    private let lock = NSLock()
    let queue = DispatchQueue(label: "com.state", qos: .default)

    init(
        state: StoreState,
        dispatcher: StoreDispatcher,
        reducer: @escaping ReducerType<StoreState, StoreDispatcher.MutationType>
    ) {
        self.state = state
        self.dispatcher = dispatcher
        self.reducer = reducer
    }
    
    func dispatch<Action>(_  action: Action) where Action == StoreDispatcher.ActionType {
        dispatcher
            .dispatch(action)
            .subscribe(on: queue)
            .receive(on: DispatchQueue.main)
            .flatMap { [unowned self] in reducer(state, $0) }
            .compactMap { $0 }
            .assign(to: &$state)
    }
}


