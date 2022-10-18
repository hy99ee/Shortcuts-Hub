import SwiftUI
import Combine

final class StateStore<StoreState, Committer, Dispatcher>:
    ObservableObject where StoreState: StateType,
                           Committer: CommitterType,
                           Dispatcher: DispatcherType,
                           Committer.CommiterState == StoreState,
                           Dispatcher.MutationType == Committer.MutationType {

    @Published var state: StoreState
    var committer: Committer
    var dispatcher: Dispatcher
    
    private let lock = NSLock()

    init(
        state: StoreState,
        committer: Committer,
        dispatcher: Dispatcher
    ) {
        self.state = state
        self.committer = committer
        self.dispatcher = dispatcher
    }

    private func commit<Mutation>(_ mutation: Mutation) -> AnyPublisher<StoreState, Never> where Mutation == Committer.MutationType {
        committer.commit(state: self.state, mutation: mutation)
    }
    
    func dispatch<Action>(_ action: Action) where Action == Dispatcher.ActionType {
        dispatcher.dispatch(action: action)
            .commit(commit)
            .assign(to: &$state)
    }
}

extension Publisher where Output: Mutation, Failure == Never {
    func commit<State: StateType>(_ commit: @escaping (Output) -> AnyPublisher<State, Never>) -> AnyPublisher<State, Never> {
        self.flatMap { commit($0) }.eraseToAnyPublisher()
    }
}

