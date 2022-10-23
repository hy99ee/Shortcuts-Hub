import Combine

var feedReducer: ReducerType<FeedState> = { state, _ in
    Just(state)
        .map { _state in
            var state = _state
            state.items = []

            return state
        }
        .eraseToAnyPublisher()
}

