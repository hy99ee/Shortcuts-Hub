import SwiftUI
import Combine

final class RootStore<StoreState, Committer, Dispatcher>:
    ObservableObject where StoreState: StateType,
                           Committer: CommitterType,
                           Dispatcher: DispatcherType,
                           Committer.CommiterState == StoreState,
                           Dispatcher.MutationType == Committer.MutationType {

    var state: StoreState
    var committer: Committer

    init(
        state: StoreState,
        committer: Committer
    ) {
        self.state = state
        self.committer = committer
    }

    func commit<Mutation>(_ mutation: Mutation) where Mutation == Committer.MutationType {
        state = committer.commit(state: self.state, mutation: mutation)
    }
    
    func dispatch<Action>(_ action: Action) where Action == Dispatcher.ActionType {
        Dispatcher(commit: self.commit).dispatch(action: action)
    }
}

