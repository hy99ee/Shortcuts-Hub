import Combine

var feedReducer: ReducerType<FeedState, FeedMutation> = { _state, mutation in
    var state = _state
    switch mutation {
    case let .fetchItems(items):
        state.items = items

    default: break
    }

    return Just(state).eraseToAnyPublisher()
}

