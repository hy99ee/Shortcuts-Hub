import Combine

protocol Mutation {}

protocol Action {}

protocol StateType {}

typealias DispatcherType<ActionType: Action, MutationType: Mutation, EnvironmentPackagesType: EnvironmentPackages> = ( _ action: ActionType, _ packages: EnvironmentPackagesType) -> AnyPublisher<MutationType, Never>

typealias ReducerType<StoreState: StateType, StoreMutation: Mutation> = (_ state: StoreState, _ mutation: StoreMutation) -> AnyPublisher<StoreState?, Never>

protocol EnvironmentType {
    associatedtype ServiceError: Error
}

protocol EnvironmentPackages {}

