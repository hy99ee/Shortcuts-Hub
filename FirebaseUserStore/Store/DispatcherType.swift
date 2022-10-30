import Combine

protocol DispatcherType {
    associatedtype ActionType: Action
    associatedtype MutationType: Mutation
    associatedtype ServiceEnvironment: EnvironmentType

    var environment: ServiceEnvironment { get }

    func dispatch(_ action: ActionType) -> AnyPublisher<MutationType, Never>
}
