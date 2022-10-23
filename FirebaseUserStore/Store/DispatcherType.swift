import Combine

protocol DispatcherType {
    associatedtype ActionType: Action
    associatedtype MutationType: Mutation
    associatedtype ServiceEnvironment: EnvironmentType

    func dispatch(_ action: ActionType, environment: ServiceEnvironment) -> AnyPublisher<MutationType, Never>
}

protocol MiddlewareType {
    func middlewareMap<ActionType>(_ action: ActionType, _ next: MiddlewareType?) -> ActionType?
}

final class AnyMiddleware: MiddlewareType {
    func middlewareMap<ActionType>(_ action: ActionType, _ next: MiddlewareType?) -> ActionType? { action }
}
