import Combine

typealias ReducerType<StoreState: StateType> = (_ state: StoreState, _ mutation: Mutation) -> AnyPublisher<StoreState?, Never>



//
//protocol ReducerType {
//  associatedtype ReducerState: StateType
//  associatedtype MutationType: Mutation
//  func reduce(state: ReducerState, mutation: MutationType) -> AnyPublisher<ReducerState, Never>
//}
