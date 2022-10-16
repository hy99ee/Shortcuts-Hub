import Foundation

struct FeedCommitter: CommitterType {
  func commit(state: FeedState, mutation: FeedMutation) -> FeedState {
    switch mutation {
    case .startMutation:
        print(state.itemBy(id: 2))
    }
      return state
  }
}
