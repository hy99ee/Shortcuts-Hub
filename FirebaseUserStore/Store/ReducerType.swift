import Combine

typealias ReducerType<StoreState: StateType> = (_ state: inout StoreState, _ mutation: Mutation, _ environment: EnvironmentType) -> AnyPublisher<StoreState, Never>


//
//protocol ReducerType {
//  associatedtype ReducerState: StateType
//  associatedtype MutationType: Mutation
//  func reduce(state: ReducerState, mutation: MutationType) -> AnyPublisher<ReducerState, Never>
//}
