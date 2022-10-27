import Combine

typealias ReducerType<StoreState: StateType, StoreMutation: Mutation> = (_ state: StoreState, _ mutation: StoreMutation) -> AnyPublisher<StoreState?, Never>
