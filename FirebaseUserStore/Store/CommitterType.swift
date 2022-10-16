import Foundation

protocol CommitterType {
  associatedtype CommiterState: StateType
  associatedtype MutationType: Mutation
  func commit(state: CommiterState, mutation: MutationType) -> CommiterState
}
