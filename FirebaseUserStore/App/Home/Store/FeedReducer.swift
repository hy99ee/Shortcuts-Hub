import Combine

var feedReducer: ReducerType = { _, _, _ in
    Just(FeedState()).eraseToAnyPublisher()
}

