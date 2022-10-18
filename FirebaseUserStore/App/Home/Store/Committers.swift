import Combine

struct FeedCommitter: CommitterType {
  func commit(state: FeedState, mutation: FeedMutation) -> AnyPublisher<FeedState, Never> {
      Just({
          var _state = state
          switch mutation {
          case .startMutation:
              _state.items = []
          }
          return _state
      }()).eraseToAnyPublisher()
  }
}
